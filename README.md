# Vegetable oils dataset
The fatty acid composition of 132 samples of different edible vegetable oils 
from the market, including pumpkin, sunflower, peanut, olive, soybean, rapeseed, 
corn and some mixed oils, determined by GC.


Source: https://www.sciencedirect.com/science/article/abs/pii/S0169743904001200


## Data cleaning

`tabulapdf` package (formerly `tabulizer`) was used to scrape tables from journal.

Two tables were scrapped:

- Table with fatty acid concentrations of oils, determined by GC.

- Table containing descriptions of unknown oils


Data cleaning was performed by cross-checking with listed number of samples in 
journal.

- 132 samples were analysed in total.

- 95 samples were of known origin

- 37 samples were of unknown origin.

- Sample ID 27 is believed to have been wrongly included in the table of known origins,
and was corrected after scraping into category of unknown origins.

Eicosanoic acid and Eicosenoic acid contents were <0.1 for some samples, and in
order for the column to contain only numeric values, samples with < 0.1 were recoded
as = 0.05. This is to help in data analysis in the future, such as clustering, 
and clustering cannot handle too many NA values. It was noted that values
were recoded as =0.1 in `modeldata` package, which is the upper bound. However,
as the value stated was less than 0.1, recoding was done to reflect that value is less 
than 0.1 (=0.05).

