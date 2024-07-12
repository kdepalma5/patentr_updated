# convert multiple XML2 files to CSV
# internal function
# date_df: column1 = year; column2 = week
# output_file should be a CSV
# returns TRUE if successful, FALSE otherwise
convert_xml2 <- function(date_df,
                         output_file, # output_file needs to be a connection to simplify things
                         header = TRUE) {
  ## TO DO: confirm valid parameters

  # create header for output file (if necessary)
  if (header) {
    cat("Doc-Number,Kind,Title,App_Date,Issue_Date,Term_of_Patent,Inventor,Applicant,Assignee,Locarno_Class,IPC_Class,CPC_Class,Related_CPC_Classes,USPC_Class,Related_USPC_Classes,References,US_Series_Code,Claims,Abstract\n",
        file = output_file)
  }

  # loop through date_df
  ans <- vapply(
    X = seq_len(nrow(date_df)),
    USE.NAMES = FALSE,
    FUN.VALUE = logical(1),
    FUN = function(row_num) {
      cat("DOWNLOADING XML2 FILE ", row_num, "...", sep = "")
      xml2_to_csv(date_df$Year[row_num], date_df$Week[row_num],
                  output_file = output_file)
      cat("DONE\n")
      TRUE
    }
  ) %>%
    unlist

  # return TRUE only if all of the downloads + conversions were successful
  ans %>% all
}

# converts single XML2 file to CSV
# always appends b/c output_file contains at least the header row
# year is always a single year (not vector w/ multiple); same for week param
xml2_to_csv <- function(year, week, output_file) {
  # download bulk file from USPTO
  temp_filename <- "temp_ans.xml"
  download_uspto(year = year, week = week, destfile = temp_filename)
  cat("PROCESSING...")

  # convert downloaded file
  xml2_to_csv_base(xml2_file = temp_filename,
                   csv_con = output_file)

  # delete downloaded file
  file.remove(temp_filename)
}

# actually does work to convert XML1 to CSV
xml2_to_csv_base <- function(xml2_file, csv_con, append = FALSE) {
  #COMMENTED THIS OUT
  #if (!append) {
   # cat("", file = csv_con, append = FALSE)
  #}

  # scope out file being converted
  pat_sizes <- get_xml_sizes(xml2_file)
  num_pats <- length(pat_sizes)

  # setup progress bar
  pb <- progress::progress_bar$new(format = "[:bar] :current/:total (:percent)",
                                   total = num_pats)
  pb$tick(0)

  # setup input
  curr_patrow <- 1
  curr_patxml <- ""
  con <- file(xml2_file, "r")
  while (curr_patrow <= num_pats) {
    # read as much as necessary for current patent
    curr_patxml <- readLines(con, n = pat_sizes[curr_patrow]) %>%
      paste0(collapse = "")

    # fix current patent w/ start and end tags
    curr_patxml <- paste0("<start>", curr_patxml, "</start>")

    ## process current patent
    curr_xml <- xml2::read_html(curr_patxml)
    doc_number <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//publication-reference//document-id//doc-number") %>%
      xml2::xml_text() %>%
      format_field_df()
    title <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//invention-title") %>%
      xml2::xml_text() %>%
      format_field_df() %>%
      remove_csv_issues()
    app_date <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//application-reference//date") %>%
      xml2::xml_text() %>%
      lubridate::as_date() %>%
      as.character() %>%
      format_field_df()
    issue_date <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//publication-reference//date") %>%
      xml2::xml_text() %>%
      lubridate::as_date() %>%
      as.character() %>%
      format_field_df()
    patent_length <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//us-bibliographic-data-grant//us-term-of-grant//length-of-grant") %>%
      xml2::xml_text() %>%
      paste0(" Years") %>%
      format_field_df()

    #extract IPC class
    ipc_class <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//classifications-ipcr//classification-ipcr") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_ipc) {
               section <- curr_ipc %>% xml2::xml_find_first(".//section") %>% xml2::xml_text()
               class <- curr_ipc %>% xml2::xml_find_first(".//class") %>% xml2::xml_text()
               subclass <- curr_ipc %>% xml2::xml_find_first(".//subclass") %>% xml2::xml_text()
               main_group <- curr_ipc %>% xml2::xml_find_first(".//main-group") %>% xml2::xml_text()
               subgroup <- curr_ipc %>% xml2::xml_find_first(".//subgroup") %>% xml2::xml_text()
               paste0(section, class, subclass, " ", main_group, "/", subgroup)
             }) %>%
      paste0(collapse = ";")

    claims <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//claims//claim//claim-text") %>%
      xml2::xml_text() %>%
      gsub(pattern = "\"", replacement = "", fixed = TRUE) %>%
      paste0(collapse = " ") %>%
      remove_csv_issues()

    # extract APPLICANT
    applicant <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-parties//us-applicants//us-applicant//addressbook") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_inv) {
               curr_first <- curr_inv %>%
                 xml2::xml_find_first(".//first-name") %>%
                 xml2::xml_text()

               curr_last <- curr_inv %>%
                 xml2::xml_find_first(".//last-name") %>%
                 xml2::xml_text()

               paste(curr_first, curr_last)
             }) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()
    
    # extract INVENTOR
    inventor <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-parties//inventors//inventor//addressbook") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_inv) {
               curr_first <- curr_inv %>%
                 xml2::xml_find_first(".//first-name") %>%
                 xml2::xml_text()
               
               curr_last <- curr_inv %>%
                 xml2::xml_find_first(".//last-name") %>%
                 xml2::xml_text()
               
               paste(curr_first, curr_last)
             }) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()

    # extract assignee
    assignee <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//assignees//assignee") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_assign) {
               curr_assign %>%
                 xml2::xml_find_first(".//addressbook//orgname") %>%
                 xml2::xml_text()
             }) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()

    # extract references
    references <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-references-cited//us-citation//patcit") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_pcit_xml) {
               # if foreign, return blank
               check_foreign <- curr_pcit_xml %>%
                 xml2::xml_find_first(".//country") %>%
                 xml2::xml_text()
               if (check_foreign != "US") return("")

               # if not foreign, return XML text
               ans <- curr_pcit_xml %>%
                 xml2::xml_find_first(".//doc-number") %>%
                 xml2::xml_text() %>%
                 strip_nonalphanum()

               return(ans)
             }) %>%
      paste0(collapse = ";") %>%
      gsub(pattern = ";;+", replacement = ";")

    # extract Series Code
    series_code <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-bibliographic-data-grant//us-application-series-code") %>%
      xml2::xml_text() %>%
      format_field_df() %>%
      remove_csv_issues()

    #extract abstract
    abstract <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//abstract//p") %>%
      xml2::xml_text() %>%
      gsub(pattern = "\"", replacement = "", fixed = TRUE) %>%
      format_field_df() %>%
      remove_csv_issues()
    
    #extract kind
    kind <- curr_xml %>%
      xml2::xml_find_first(".//us-patent-grant//us-bibliographic-data-grant//publication-reference//document-id//kind") %>%
      xml2::xml_text() %>%
      format_field_df()

    # extract CPC class
    main_cpc_class <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-bibliographic-data-grant//classifications-cpc//main-cpc//classification-cpc") %>%
      vapply(USE.NAMES = FALSE,
             FUN.VALUE = character(1),
             FUN = function(curr_cpc) {
               section <- curr_cpc %>% xml2::xml_find_first(".//section") %>% xml2::xml_text()
               class <- curr_cpc %>% xml2::xml_find_first(".//class") %>% xml2::xml_text()
               subclass <- curr_cpc %>% xml2::xml_find_first(".//subclass") %>% xml2::xml_text()
               main_group <- curr_cpc %>% xml2::xml_find_first(".//main-group") %>% xml2::xml_text()
               subgroup <- curr_cpc %>% xml2::xml_find_first(".//subgroup") %>% xml2::xml_text()
               paste0(section, class, subclass, " ", main_group, "/", subgroup)
             }) %>%
      paste0(collapse = ";")
    
    # extract related CPC classes
    related_cpc_class <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-bibliographic-data-grant//us-field-of-classification-search//classification-cpc-text") %>%
      xml2::xml_text() %>%
      gsub(pattern = "\"", replacement = "", fixed = TRUE) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()
    
    # extract Locarno International Classification of Design
    locarno_class<- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-bibliographic-data-grant//classification-locarno//main-classification") %>%
      xml2::xml_text() %>%
      gsub(pattern = "\"", replacement = "", fixed = TRUE) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()

        # extract USPC class
      main_uspc_class <- curr_xml %>%
        xml2::xml_find_first(".//us-patent-grant//us-bibliographic-data-grant//classification-national//main-classification") %>%
        xml2::xml_text() %>%
        format_field_df() %>%
        remove_csv_issues()
      
      further_uspc_class <- curr_xml %>%
        xml2::xml_find_first(".//us-patent-grant//us-bibliographic-data-grant//classification-national//further-classification") %>%
        xml2::xml_text() %>%
        format_field_df() %>%
        remove_csv_issues()
      
      if((further_uspc_class == "NA") && (main_uspc_class == "None")){
        uspc_class <- ""
      } else if(further_uspc_class == "NA"){
        uspc_class <- main_uspc_class
      } else if (main_uspc_class == "None"){
        uspc_class <- further_uspc_class
      } else {
        uspc_class <- paste0(main_uspc_class, ";", further_uspc_class)
      }
    
    # extract related USPC classes
    related_uspc_class <- curr_xml %>%
      xml2::xml_find_all(".//us-patent-grant//us-bibliographic-data-grant//us-field-of-classification-search//classification-national//main-classification") %>%
      xml2::xml_text() %>%
      gsub(pattern = "\"", replacement = "", fixed = TRUE) %>%
      paste0(collapse = ";") %>%
      remove_csv_issues()

    # output to file in CSV format
    cat(paste0("\"",doc_number,"\",",
               "\"",kind,"\",",
               "\"",title,"\",",
               app_date,",",
               issue_date,",",
               "\"",patent_length,"\",",
               "\"",inventor,"\",",
               "\"",applicant,"\",",
               "\"",assignee,"\",",
               "\"",locarno_class,"\",",
               "\"",ipc_class,"\",",
               "\"",main_cpc_class,"\",",
               "\"",related_cpc_class,"\",",
               "\"",uspc_class,"\",",
               "\"",related_uspc_class,"\",",
               "\"",references,"\",",
               "\"",series_code,"\",",
               "\"",claims,"\",",
               "\"",abstract,"\"\n"),
        file = csv_con,
        append = TRUE)

    # update loop vars
    pb$tick()
    curr_patrow <- curr_patrow + 1
    curr_patxml <- ""
  }
  close(con)
}
