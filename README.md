# Lexical & Syntax/Semantic Analyzer
Compiler pipeline for MailScript, a language dedicated to send and schedule emails.
# Installation
Clone the repository and make sure you have flex and GNU Bison installed.
After cloning the repository, you can follow these steps to build the compiler:

```bison -d parser.y```

```flex lexicalAnalyzer.flx```

```gcc -o compiler lex.yy.c parser.tab.c -lfl -g```

Then, you can test the program or feed your own text files like this:

```./compiler < test10.ms```




