library(shiny)
library(tesseract)
library(magick)

# Define UI
ui <- fluidPage(
  titlePanel("PDF to TXT Converter"),
  fileInput("pdf_file", "Choose a PDF file"),
  actionButton("convert_btn", "Convert to TXT"),
  downloadButton("download_txt", "Download TXT")
)
