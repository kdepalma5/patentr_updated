# patentr_updated

## Extension to [JYProys patentr](https://github.com/JYProjs/patentr) R package 
This enhanced version of the `patentr` package facilitates easy access to USPTO bulk patent data by downloading and collecting the specified metadata listed below and outputting it into a CSV file.

# This updated version collects the following metadata for each patent that is stored in XML2 format:
- Doc-Number
- Kind
- Title
- Application date
- Issue date
- Term of patent
- Inventor name(s)
- Applicant name(s)
- Assignee name(s)
- Assignee role(s)
- Locarno classification
- IPC classification(s)
- Main CPC, Further CPC, and Related CPC classifications
- Main USPC, Further USPC, and Related USPC classifications
- References
- U.S. series code
- Claims
- Abstract

According to the original `patentr` package, patents issued in 2005 or later are in XML2 format. However, for optimal results, this version is recommended for patents issued after 2013. The primary modifications from the original package are in the `convert_xml2.R` and `acquire.R` files.

# Sample code as shown by JYProys:

```R
# load patentr
library("patentr")

# download patents from the first week of 1976
get_bulk_patent_data(year = 1976,
                     week = 1,
                     output_file = "patent_output1.csv")

# download patents from:
#   1. week 1 of 1976 (TXT format in USPTO)
#   2. week 48 of 2002 (XML format 1 in USPTO)
#   3. week 19 of 2006 (XML format 2 in USPTO)
# N.B. it will take a few minutes to run the next line
get_bulk_patent_data(year = c(1976, 2002, 2006),
                     week = c(1, 48, 19),
                     output_file = "patent_output2.csv")

# download patents from the last 5 weeks of 1980 (and write to a file)
get_bulk_patent_data(year = rep(1980, 5),
                     week = 48:52,
                     output_file = "patent-data.csv")
```

For more information go to [JYProys patentr](https://github.com/JYProjs/patentr)
