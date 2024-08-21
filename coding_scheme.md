# AI Coding Scheme to Classify Patents

Below is a table listing 11 AI classifications along with their definitions, which are used to categorize AI-related patents. This coding scheme is designed to be both mutually exclusive and collectively exhaustive. 

| AI Application | Definition | 
| --- | --- |
| **Image Recognition** | The analysis of objects, information, and details that are present in a still image. Examples include facial recognition, text analysis (simply reading text, not to be confused with comprehension). The PRIMARY objectives are to correctly recognize whether or not specific subjects are present and determine the number of subjects present without necessarily considering the broader context or actions depicted.<br><br>Example: Properly identify whether or not an image contains Michael Jordan’s face |
| **Contextual Image Analysis** | The recognition of events, spatial relationships, and context from a still image. While image recognition still occurs, the PRIMARY objectives are to comprehend the context and underlying structures within an image. This might include analyzing how objects interact, detecting motion, or identifying specific patterns that suggest relationships or actions.<br><br>Example: Properly identify that the image is of a man shooting a basketball |
| **Reading Comprehension** | The ability to answer simple reasoning questions based on an understanding of content that is PRIMARILY text. The PRIMARY objectives of such comprehension should be to CORRECTLY analyze and respond to prompts and maintain the accuracy of information.<br><br>Example: Summarizing news articles |
| **Language Modeling** | The ability to model, predict, or mimic human language. PRIMARY focuses of such modeling should be accurate grammar, pattern recognition, and sentence structure, typically constructing statements from scratch.<br><br>Examples: GPT models (although many models in this category are likely less advanced), digital assistants |
| **Translation** | The translation of words or text from one language into another.<br><br>Unlike reading comprehension or language modeling, emphasis is placed on relationships between words and choosing correct vocabulary based on context. |
| **Speech Recognition** | The recognition and/or transcription of spoken language into text. Given that spoken language is often different from written language, this is a distinct category that also includes identifying proper punctuation and word choice based on tone and emphasis, as well as identifying speakers based on the sounds of their voices. |
| **Musical Track Recognition** | The recognition of existing musical tracks from audio input data. |
| **Media Generation** | The creation of any form of media (audio/video/images) from a prompt or set of input data.<br><br>While this process may involve speech recognition, image recognition, or contextual image analysis, the PRIMARY output is the generation of new media from specified input. |
| **Navigation** | Utilizing the ability to correctly identify or create the best possible route, often using real-time traffic updates and different road conditions. |
| **Predictive Analysis** | The use of statistical techniques and machine learning models to analyze current and historical data to make predictions about future events or trends.<br><br>Examples include predicting traffic patterns, individuals’ daily routines, and optimizing resource usage. |
| **Gaming/Strategy** | Utilizing the ability to play games with known rules, output information, and input information.<br><br>The key distinctions within this category are decisiveness and adaptability. Models are expected to act with an understanding of cause/effect and make a series of decisions independently, without human intervention. |

## Interrater Reliability (IRR)

This coding scheme achieved an IRR of 0.922 with three raters, indicating excellent consistency. 

The R script for calculating the IRR takes a CSV file as input, which contains the classifications from each rater. The code for this script is shown below: 
``` R
setwd("path") #Provide a path of your choice
library(irr)

data <- read.csv("irr_data.csv")

# Classification
classification <- cbind(data[4:6])
kappam.fleiss(classification, exact = T)
kappa2(data[4:5], weight = "unweighted") # Rater 1 and Rater 2
kappa2(data[5:6], weight = "unweighted") # Rater 2 and Rater 3
kappa2(cbind(data[4], data[6]), weight = "unweighted") # Rater 1 and Rater 3

```



## Relevant CPC/IPC codes
During our analysis of various patents, we compiled a list of relevant CPC/IPC codes that correspond to specific AI classifications listed in the table below.

| AI Application | Relevant CPC/IPC Codes |
| --- | --- |
| Image Recognition | G06K9: Recognition of characters or patterns<br>G06T3: Image Transformation<br>G06T5: Image enhancement/ restoration<br>G06T7: Image Analysis<br>G06V20: Scenes; Scene-specific elements<br>G06V30: Character recognition; Recognising digital ink; Document-oriented image-based pattern recognition<br>G06V40: Recognition of biometric, human-related, or animal-related patterns in image or video data |
| Contextual Image Analysis | G06T7: Image Analysis<br>G06V20: Scenes; Scene-specific elements (and derives context) |
| Speech Recognition | G10L15: Speech Recognition<br>G10L17: Speaker Identification<br>G10L21: Processing of Speech or Voice Signal<br>G10L25: Speech or voice analysis<br>G10L13: Speech synthesis |
| Media Generation | G06T 11: 2D image generation<br>G10L 13: Speech synthesis; Text to speech systems |
| Navigation | G08G 1: Traffic control systems for road vehicles |
| Gaming/Strategy | A63F: Card, board, or roulette games; indoor games using small moving playing bodies; video games; games not otherwise provided for |




