#Installing all the packages and data that I need to clean and analyze 

install.packages("tidyverse")
library("tidyverse")
library("lubridate")
install.packages("skimr")
library("skimr")
install.packages("janitor")
library('janitor')
install.packages("palmerpenguins")
library(palmerpenguins)

#Let's check if the data was installed properly

skim_without_charts(penguins)
glimpse(penguins)
head(penguins)

#Let's perform some simple data cleaning functions to make sure everything looks good

#clean_name function ensures there are only characters, numbers, and underscores in the names
clean_names(penguins)

#rename all columns with lowercase letters
rename_with(penguins, tolower)


#this allows us to look at the species data
penguins %>% 
  select(species)

#this allows us to look at everything but the species data
penguins %>% 
  select(-species)

#using arrange function
penguins %>% 
  arrange(bill_length_mm)

penguins %>% 
  arrange(-bill_length_mm)

penguins_2 <- penguins %>% arrange(-bill_length_mm)
view(penguins_2)

#using group by function
penguins %>% 
  group_by(island) %>%  drop_na() %>% summarize(mean_bill_length_mm = mean(bill_length_mm))

penguins %>% group_by(island) %>% drop_na() %>% summarize(max_bill_length_mm = max(bill_length_mm))

penguins %>% group_by(species, island) %>% drop_na() %>% summarize(max_bl=max(bill_length_mm), mean_bl=mean(bill_length_mm))

# "==" means exactly equal to
penguins %>% filter(species == "Adelie")

#Using ggplot2 and creating different charts

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g))

ggplot(data= penguins) + geom_point(mapping= aes(x= bill_length_mm, y= bill_depth_mm))

#this scatter plot has data points that shows the the different species by color and shape

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g, color= species, shape= species))

#Alpha is helpful to make data points transparent for each species  

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g, alpha= species))

#Having the color purple outside of the aes function allows for all data points to reflect a single color

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g), color= "purple")

#facet functions is very helpful to display the different graphs for each data point

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g, color= species, shape= species))+
  facet_wrap(~species) 
#This facet function shows the different sex and species for the penguins (too busy and becomes harder to make an analysis from so many charts)

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g, color= species))+
  facet_grid(sex~species)

#This creates a smooth line graph

ggplot(data= penguins) + geom_smooth(mapping= aes(x= flipper_length_mm, y= body_mass_g))

#Lets add some labels and annotations to some of these graphs

ggplot(data= penguins) + geom_point(mapping= aes(x= flipper_length_mm, y= body_mass_g, color= species)) + geom_smooth(mapping= aes(x= flipper_length_mm, y= body_mass_g)) +
  labs(title="Palmer Penguins: Body Mass vs. Flipper Length", subtitle = "Sample of Three Penguin Species", caption="Data Collected By Dr. Kristen Gorman")+
  annotate("text", x=220, y=3500,label="The Gentoos are the largest", color="purple", fontface= "bold", size= 4.5, angle=25)

#Let's save this graph as a .png 

ggsave('Three Penguins Species.png')

