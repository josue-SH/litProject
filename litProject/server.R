library(shiny)
library(shinyjs)
library(tesseract)
library(magick)
library(zip)

# Define server
server <- function(input, output) {
  #converted_text <- reactiveVal(NULL)
  
  observeEvent(input$convert_btn, {
    req(input$pdf_file)
    pdf_file_path <- input$pdf_file$datapath
    
    # Create a temporary directory
    shiny_dir <- tempdir(check = TRUE)
    setwd(shiny_dir)
    
    # Convert PDF to PNG
    png_files <- pdftools::pdf_convert(pdf_file_path, dpi = 600)
    
    # Process PNG files using Magick package
    magick_images <- lapply(png_files, magick::image_read)
    
    # Setting up the Tesseract OCR engine
    eng <- tesseract::tesseract("eng")
    
    # Function for generating TXT files from PNG files
    generate_txt <- function(input){
      input |>
        magick::image_resize("2000x") |>
        magick::image_convert(type = "Grayscale") |>
        tesseract::ocr(engine = eng)
    }
    
    # Create directory for TXT files if not exists
    if (!dir.exists("texts")) {
      dir.create("texts")
    }
    
    # Loop through image directory
    for (j in seq_along(magick_images)) {
      file_conn <- file(shiny_dir, paste0("text_", j, ".txt"))
      writeLines(generate_txt(magick_images[[j]]), file_conn)
      close(file_conn)
    }
    
    
    text_zip <- zip::zip(zipfile = "textFiles.zip", 
                         list.files(shiny_dir, full.names = TRUE))
    
    #converted_text(readLines(paste0("./texts/text_", 1:length(magick_images), ".txt")))
    
    #file.remove(png_files)
    #file.remove(list.files("./texts"))
  
    output$zip_file <- renderText({
      text_zip
    })
    
    
    
    # Enable download button
    shinyjs::enable("download_txt")
    
    })
  
  output$download_txt <- downloadHandler(
    filename = function() {
      "converted_txt.zip"
    },
    content = function(file) {
      file.copy(output$zip_file, file)
    }
  )
  
  # Disable the download button intially
  shinyjs::disable("download_txt")
  
}