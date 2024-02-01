library(shiny)
library(shinyjs)
library(tesseract)
library(magick)
library(zip)

# Define UI
ui <- fluidPage(
  titlePanel("PDF to TXT Converter"),
  fileInput("pdf_file", "Choose a PDF file"),
  actionButton("convert_btn", "Convert to TXT"),
  useShinyjs(),
  downloadButton("download_txt", "Download TXT")
)
