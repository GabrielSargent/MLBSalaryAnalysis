library(tidyverse)
library(ggplot2)

###############
#Data Cleaning#
###############


#Import data
salaries <- read.csv("data/raw/Salaries.csv")
master <- read.csv("data/raw/Master.csv")
batting <- read.csv("data/raw/Batting.csv")
pitching <- read.csv("data/raw/Pitching.csv")


#filtering out data prior to 1985 (earliest year available for salaries dataset)
batting85 <- batting %>%
  filter(yearID >= 1985, AB >=50)

head(batting85)


#joining the datasets
batsal85 <- batting85 %>%
  inner_join(salaries, by=c('playerID', 'yearID', 'teamID', 'lgID'), relationship="many-to-many")

head(batsal85)


#figuring out what all the team ID's are. I need to rename some of them to keep 
#things consistent over time
table(batsal85$teamID)


#first, I will join batsal85 with the master dataset, and I will also anti-join
#it with the pitching dataset to remove pitchers who also hit (exclusive to NL 
#teams)
head(master)

mastername <- master %>%
  select(playerID, FirstName=nameFirst, LastName=nameLast)

batmas85 <- batsal85 %>%
  inner_join(mastername, by=c('playerID'))

morepitch <- pitching %>%
  filter(IPouts >=54) #attempts to rule out any instances of position players 
                      #pitching since presumably they would not pitch for more 
                      #than 54 outs (18 innings)

justbatmas85 <- batmas85 %>%
  anti_join(morepitch, by='playerID')

head(justbatmas85)


#here I am finally adjusting the teams
fixbatmas <- justbatmas85 %>%
  mutate(teamID = case_when(
    teamID == "FLO" ~ "MIA",
    teamID == "TBA" ~ "TBR",
    teamID == "CAL" ~ "LAA",
    teamID == "ANA" ~ "LAA",
    teamID == "CHA" ~ "CHW",
    teamID == "CHN" ~ "CHC",
    teamID == "KCA" ~ "KCR",
    teamID == "ML4" ~ "MIL",
    teamID == "MON" ~ "WAS",
    teamID == "NYN" ~ "NYM",
    teamID == "NYA" ~ "NYY",
    teamID == "LAN" ~ "LAD",
    teamID == "SFN" ~ "SFG",
    teamID == "SLN" ~ "STL",
    teamID == "SDN" ~ "SDP", TRUE ~ teamID )
    
  )

table(fixbatmas$teamID)


#I now have each hitter (with enough AB's in my opinion to qualify as a hitter) 
#along with their salary and game stats. What I want to do here is, for a couple
#specific years, map out certain predictors vs salary.

#First, I will add a few stats not included in the original batting stats. 
#These will not be original stats, but instead percentage based stats (batting 
#average, on base percentage, etc.) since the original one prefers counting stats

total <- fixbatmas %>%
  mutate(Avg = H / AB,
         Slg = (HR*4 + `X3B`*3 + `X2B`*2 + (H - HR - `X3B` - `X2B`)) / AB,
         OBP = (H + BB + HBP) / (AB + BB + HBP),
         OPS = OBP + Slg
  )

head(total)

#The data lists Dion James is listed as being paid 0 dollars in 1993 (obs. 2997).
#I suspect this is a data entry error, since this is literally impossible. So
#let's just delete that observation, since it will mess with some of the 
#analysis later.

total <- total[-2997,]

#Write out cleaned data.
write.csv(total, "data/processed/data.csv", row.names = F)


###########################
#Exploratory Data Analysis#
###########################

#Here I will map average salary over time across all hitters. It does increase substantially.

avg_salary <- total %>%
  group_by(yearID) %>%
  summarize(mean_salary = mean(salary))


ggplot(data=avg_salary, aes(x = yearID, y = mean_salary)) +
  geom_line(color = "red") +
  geom_point() +
  labs(
    title = "Average MLB Salary by Year",
    x = "Year",
    y = "Average Salary ($)" ) +
  theme_minimal()

#Now I will separate this by team. I will acknowledge here I used ChatGPT to give a list of the official hex codes for each of the 30 current mlb teams

mlb_colors <- c(
  ARI = "#A71930", # Diamondbacks – Sedona Red  
  ATL = "#CE1141", # Braves – Scarlet  
  BAL = "#DF4601", # Orioles – Orange  
  BOS = "#BD3039", # Red Sox – Red  
  CHC = "#0E3386", # Cubs – Blue  
  CHW = "#27251F", # White Sox – Black  
  CIN = "#C6011F", # Reds – Red  
  CLE = "#E50022", # Guardians – Red  
  COL = "#333366", # Rockies – Purple  
  DET = "#FA4616", # Tigers – Orange  
  HOU = "#EB6E1F", # Astros – Orange  
  KCR  = "#004687", # Royals – Royal Blue  
  LAA = "#CE0F41", # Angels – Red  
  LAD = "#005A9C", # Dodgers – Dodger Blue  
  MIA = "#0077C8", # Marlins – “Blue”  
  MIL = "#FFC52F", # Brewers – Gold  
  MIN = "#002B5C", # Twins – Navy Blue  
  NYM = "#002D72", # Mets – Blue  
  NYY = "#132448", # Yankees – Navy Blue  
  OAK = "#EFB21E", # Athletics – Yellow  
  PHI = "#E81828", # Phillies – Red  
  PIT = "#27251F", # Pirates – Black  
  SDP  = "#2F241D", # Padres – Navy (or Brown-ish)  
  SFG  = "#FD5A1E", # Giants – Orange  
  SEA = "#005C5C", # Mariners – Teal  
  STL = "#C41E3A", # Cardinals – Red  
  TBR  = "#8FBCE6", # Rays – Light Blue  
  TEX = "#003278", # Rangers – Royal Blue  
  TOR = "#134A8E", # Blue Jays – Royal Blue  
  WAS = "#AB0003"  # Nationals – Red
)

avg_salary_team <- total %>%
  group_by(teamID, yearID) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_team, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors) +
  labs(
    title = "Average Salary by Team and Year",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#The above is quite cluttered. I will separate by division. This first one is the NL West

avg_salary_teamNW <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("LAD", "COL", "ARI", "SDP", "SFG")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamNW, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors) +
  labs(
    title = "Average Salary by Team and Year (NL West)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#NL Central

avg_salary_teamNC <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("CHC", "CIN", "MIL", "STL", "PIT")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamNC, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors) +
  labs(
    title = "Average Salary by Team and Year (NL Central)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#NL East

avg_salary_teamNE <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("ATL", "WAS", "NYM", "PHI", "MIA")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamNE, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors) +
  labs(
    title = "Average Salary by Team and Year (NL East)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#AL West

avg_salary_teamAW <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("HOU", "TEX", "LAA", "OAK", "SEA")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamAW, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors)+
  labs(
    title = "Average Salary by Team and Year (AL West)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#AL Central

avg_salary_teamAC <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("CHW", "CLE", "DET", "MIN", "KCR")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamAC, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors)+
  labs(
    title = "Average Salary by Team and Year (AL Central)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#AL East

avg_salary_teamAE <- total %>%
  group_by(teamID, yearID) %>%
  filter(teamID %in% c("NYY", "BOS", "TOR", "TBR", "BAL")) %>%
  summarize(mean_team_salary = mean(salary, na.rm = TRUE), .groups = "drop")

ggplot(avg_salary_teamAE, aes(yearID, mean_team_salary, color = teamID)) +
  geom_line(size = 1) +
  geom_point(color='black') +
  scale_color_manual(values = mlb_colors)+
  labs(
    title = "Average Salary by Team and Year (AL East)",
    x = "Year",
    y = "Average Salary",
    color = "Team"
  ) +
  theme_minimal()


#Now let's plot salary vs On-base Plus Slugging (OPS) for different years.
#1985
total85 <- total %>%
  filter(yearID==1985)

ggplot(data=total85) +
  geom_point(aes(x=OPS, y=salary)) +
  geom_smooth(aes(x=OPS, y=salary), color="red") +
  labs(title="Player OPS vs. Salary (1985)", 
       x="OPS",
       y="Salary ($)" ) +
  theme_minimal()


#1995
total95 <- total %>%
  filter(yearID==1995)

ggplot(data=total95) +
  geom_point(aes(x=OPS, y=salary)) +
  geom_smooth(aes(x=OPS, y=salary), color="blue") +
  labs(title="Player OPS vs. Salary (1995)", 
       x="OPS",
       y="Salary ($)" ) +
  theme_minimal()


#2005
total05 <- total %>%
  filter(yearID==2005)

ggplot(data=total05) +
  geom_point(aes(x=OPS, y=salary)) +
  geom_smooth(aes(x=OPS, y=salary), color="orange") +
  labs(title="Player OPS vs. Salary (2005)", 
       x="OPS", y="Salary ($)" ) +
  theme_minimal()


#2015
total15 <- total %>%
  filter(yearID==2015)

ggplot(data=total15) +
  geom_point(aes(x=OPS, y=salary)) +
  geom_smooth(aes(x=OPS, y=salary), color="green2") +
  labs(title="Player OPS vs. Salary (2015)", 
       x="OPS",
       y="Salary ($)" ) +
  theme_minimal()
