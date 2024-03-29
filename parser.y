%{
#ifdef YYDEBUG
  yydebug = 1;
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "classes.h"
void yyerror (const char *msg) /* Called by yyparse on error */ {return; }

IdentNode globalVariableList[100];
int globalVariableListIndex = 0;

IdentNode localVariableLists[100][100];
int mailBlockIndex = -1;
int localVariableListSize[100];

int error = 0;

char **errors;
int errorIndex = 0;

char **sendPrints;
int sendPrintIndex = 0;

ScheduleStatementPrint schedulePrints[100];
int schedulePrintIndex = 0;

void addPrefixToStrings(char** strings, size_t size, int previous,char* prefix);
void addStringToMessage(ScheduleStatementPrint arr[], int size, int previous, char *stringToBeAdded);

int searchVariableList(IdentNode variableList[], int size, char *variable);
void printVariableList(IdentNode variableList[], int size);
void printRecipientNodes(RecipientNode* array, int size);
int isValuePresent(char** array, int arraySize, char* value);
void printCharArray(char** array, int size);

int comparePrints(const void *a, const void *b);
void sortScheduledPrints(ScheduleStatementPrint scheduledPrints[], int size);

int isValidTime(char* time);
int isValidDate(char* date);
int isLeapYear(int year);

char* extractMonth(char* date);
char* extractYear(char* date);

void printScheduleMessages(ScheduleStatementPrint schedule[], int size);

int previousPrintIndex = 0;
int previousSchedulePrintIndex = 0;

IdentNode *head = NULL;

%}
%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tTO tFROM tSET tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT

%token <identNode> tIDENT
%token <stringNode> tSTRING
%token <sendTokenNode> tSEND
%token <adressNode> tADDRESS
%token <dateNode> tDATE
%token <timeNode> tTIME


%type <programNode> program
%type <statementsNode> statements
%type <mailBlockNode> mailBlock
%type <statementListNode> statementList
%type <sendStatementsNode> sendStatements
%type <sendStatementNode> sendStatement
%type <scheduleStatementNode> scheduleStatement
%type <setStatementNodePtr> setStatement
%type <recipientNode> recipient
%type <recipientListNode> recipientList

%union{
    IdentNode identNode;
    StringNode stringNode;
    SendTokenNode sendTokenNode;
    AdressNode adressNode;
    DateNode dateNode;
    TimeNode timeNode;
    
    ProgramNode programNode;
    StatementListNode statementListNode;
    StatementsNode statementsNode;
    SetStatementNode *setStatementNodePtr;
    SendStatementsNode sendStatementsNode;
    SendStatementNode sendStatementNode;
    MailBlockNode mailBlockNode;
    ScheduleStatementNode scheduleStatementNode;
    RecipientNode recipientNode;
    RecipientListNode recipientListNode;
}

%start program
%%

program : statements{
          }  
;

statements : {
               }
               | statements setStatement{
                globalVariableList[globalVariableListIndex].identName = strdup($2->setStatementIdentName);
                globalVariableList[globalVariableListIndex].identValue = strdup($2->setStatementIdentValue);  
                globalVariableListIndex++;      
                }  

              | statements mailBlock {
              }          
;

mailBlock : tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL{
                $$.scheduleStatementList = $5.scheduleStatementList;
                $$.scheduleStatementListSize = $5.scheduleStatementListSize;
                char *concatenatedString = (char *)malloc(1000);
                strcpy(concatenatedString, "E-mail sent from ");
                strcat(concatenatedString, $3.value);
                strcat(concatenatedString, " ");  
                addPrefixToStrings(sendPrints, sendPrintIndex, previousPrintIndex, concatenatedString);
                previousPrintIndex = sendPrintIndex;
                char *newMail = (char *)malloc(100);
                strcpy(newMail, $3.value);
                strcat(newMail, " ");  
                addStringToMessage(schedulePrints, schedulePrintIndex, previousSchedulePrintIndex, newMail);
                previousSchedulePrintIndex = schedulePrintIndex;
                }           
;

statementList : {
                mailBlockIndex++;
                localVariableListSize[mailBlockIndex] = 0;
                
                $$.sendStatementList = (SendStatementNode*)malloc(100 * sizeof(SendStatementNode));
                $$.sendStatementListSize = 0;
                $$.scheduleStatementList = (ScheduleStatementNode*)malloc(100 * sizeof(ScheduleStatementNode));
                $$.scheduleStatementListSize = 0;
              }
              | statementList setStatement{ 
                localVariableLists[mailBlockIndex][localVariableListSize[mailBlockIndex]].identName = strdup($2->setStatementIdentName);
                localVariableLists[mailBlockIndex][localVariableListSize[mailBlockIndex]].identValue = strdup($2->setStatementIdentValue);
                localVariableListSize[mailBlockIndex]++;
              }
              
              | statementList sendStatement {
                $$.sendStatementList = $1.sendStatementList;
                $$.sendStatementListSize = $1.sendStatementListSize;

                $$.scheduleStatementList = $1.scheduleStatementList;
                $$.scheduleStatementListSize = $1.scheduleStatementListSize;

                $$.sendStatementList[$$.sendStatementListSize] = $2;
                ($$.sendStatementListSize)++;

                char *message;
                if (strcmp($2.ident, "None")) {
                  int size = localVariableListSize[mailBlockIndex];
                  int index =
                      searchVariableList(localVariableLists[mailBlockIndex], size, $2.ident);
                  if (index >= 0) {
                    message = localVariableLists[mailBlockIndex][index].identValue;
                  } else {
                    index = searchVariableList(globalVariableList, globalVariableListIndex, $2.ident);
                    if (index >= 0) {
                      message = globalVariableList[index].identValue;
                    }
                    // ERROR
                    else {
                      error = 1;
                      char error[100];
                      char numStr[20];
                      sprintf(numStr, "%d", $2.linenum);
                      strcpy(error, "ERROR at line ");
                      strcat(error, numStr);
                      strcat(error, ": ");
                      strcat(error, $2.ident);
                      strcat(error, " is undefined");
                      errors[errorIndex] = strdup(error);
                      errorIndex++;
                    }
                  }
                } else {
                  message = $2.string;
                }
                char **alreadySent = (char **)malloc(100 * sizeof(char *));
                int alreadySentIndex = 0;
                int i = 0;
                for (; i < $2.recipientListSize; i++) {
                  char *receiver;
                  if (strcmp($2.recipientList[i].ident, "None") != 0) {
                    int size = localVariableListSize[mailBlockIndex];
                    int index = searchVariableList(localVariableLists[mailBlockIndex], size, $2.recipientList[i].ident);
                    if (index >= 0) {
                      receiver = localVariableLists[mailBlockIndex][index].identValue;
                    } else {
                      index = searchVariableList(globalVariableList, globalVariableListIndex, $2.recipientList[i].ident);
                      if (index >= 0) {
                        receiver = globalVariableList[index].identValue;
                      }
                      // ERROR
                      else {
                        error = 1;
                        char error[100];
                        char numStr[20];
                        sprintf(numStr, "%d", $2.recipientList[i].linenum);
                        strcpy(error, "ERROR at line ");
                        strcat(error, numStr);
                        strcat(error, ": ");
                        strcat(error, $2.recipientList[i].ident);
                        strcat(error, " is undefined");
                        errors[errorIndex] = strdup(error);
                        errorIndex++;
                      }
                    }
                  } else if (strcmp($2.recipientList[i].string, "None") != 0) {
                    receiver = $2.recipientList[i].string;
                  } else {
                    receiver = $2.recipientList[i].adress;
                  }
                  if (!error) {
                    if (!isValuePresent(alreadySent, alreadySentIndex, $2.recipientList[i].adress)) {
                      char sendMessage[1000];
                      strcpy(sendMessage, "to ");
                      strcat(sendMessage, receiver);
                      strcat(sendMessage, ": ");
                      strcat(sendMessage, "\"");
                      strcat(sendMessage, message);
                      strcat(sendMessage, "\"");
                      sendPrints[sendPrintIndex] = strdup(sendMessage);
                      sendPrintIndex++;
                      alreadySent[alreadySentIndex] = $2.recipientList[i].adress;
                      alreadySentIndex++;
                    }
                  }
                }
              }

              | statementList scheduleStatement{
                $$.sendStatementList = $1.sendStatementList;
                $$.sendStatementListSize = $1.sendStatementListSize;

                $$.scheduleStatementList = $1.scheduleStatementList;
                $$.scheduleStatementListSize = $1.scheduleStatementListSize;

                $$.scheduleStatementList[$$.scheduleStatementListSize] = $2;
                ($$.scheduleStatementListSize)++;
                if(isValidDate($2.date)){
                    error = 1;
                    char error[1000];
                    char numStr[20];
                    sprintf(numStr, "%d", $2.linenum);
                    strcpy(error, "ERROR at line ");
                    strcat(error, numStr);
                    strcat(error, ": date object is not correct (");
                    strcat(error, $2.date);
                    strcat(error, ")");
                    errors[errorIndex] = strdup(error);
                    errorIndex++;
                }
                 if(isValidTime($2.time)){
                    error = 1;
                    char error[1000];
                    char numStr[20];
                    sprintf(numStr, "%d", $2.linenum);
                    strcpy(error, "ERROR at line ");
                    strcat(error, numStr);
                    strcat(error, ": time object is not correct (");
                    strcat(error, $2.time);
                    strcat(error, ")");
                    errors[errorIndex] = strdup(error);
                    errorIndex++;
                }
                int i = 0;
                for(; i < $2.sendStatementListSize; i++){
                  char *message;
                  if (strcmp($2.sendStatementList[i].ident, "None")) {
                    int size = localVariableListSize[mailBlockIndex];
                    int index = searchVariableList(localVariableLists[mailBlockIndex], size, $2.sendStatementList[i].ident);
                    if (index >= 0) {
                      message = localVariableLists[mailBlockIndex][index].identValue;
                    } else {
                      index = searchVariableList(globalVariableList, globalVariableListIndex, $2.sendStatementList[i].ident);
                      if (index >= 0) {
                        message = globalVariableList[index].identValue;
                      }
                      // ERROR
                      else {
                        error = 1;
                        char error[100];
                        char numStr[20];
                        sprintf(numStr, "%d", $2.sendStatementList[i].linenum);
                        strcpy(error, "ERROR at line ");
                        strcat(error, numStr);
                        strcat(error, ": ");
                        strcat(error, $2.sendStatementList[i].ident);
                        strcat(error, " is undefined");
                        errors[errorIndex] = strdup(error);
                        errorIndex++;
                      }
                    }
                  } else{
                    message = $2.sendStatementList[i].string;
                  }
                  char **alreadySent = (char **)malloc(100 * sizeof(char *));
                  int alreadySentIndex = 0;
                  int k = 0;
                  for (; k < $2.sendStatementList[i].recipientListSize; k++) {
                    char *receiver;
                    if (strcmp($2.sendStatementList[i].recipientList[k].ident, "None") != 0) {
                      int size = localVariableListSize[mailBlockIndex];
                      int index = searchVariableList(localVariableLists[mailBlockIndex], size, $2.sendStatementList[i].recipientList[k].ident);
                      if (index >= 0) {
                        receiver = localVariableLists[mailBlockIndex][index].identValue;
                      } else {
                        index = searchVariableList(globalVariableList, globalVariableListIndex, $2.sendStatementList[i].recipientList[k].ident);
                        if (index >= 0) {
                          receiver = globalVariableList[index].identValue;
                        }
                        // ERROR
                        else {
                          error = 1;
                          char error[100];
                          char numStr[20];
                          sprintf(numStr, "%d", $2.sendStatementList[i].recipientList[k].linenum);
                          strcpy(error, "ERROR at line ");
                          strcat(error, numStr);
                          strcat(error, ": ");
                          strcat(error, $2.sendStatementList[i].recipientList[k].ident);
                          strcat(error, " is undefined");
                          errors[errorIndex] = strdup(error);
                          errorIndex++;
                        }
                      }
                    } else if (strcmp($2.sendStatementList[i].recipientList[k].string, "None") != 0) {
                      receiver = $2.sendStatementList[i].recipientList[k].string;
                    } else {
                      receiver = $2.sendStatementList[i].recipientList[k].adress;
                    }
                    if (!error) {
                      if (!isValuePresent(alreadySent, alreadySentIndex, $2.sendStatementList[i].recipientList[k].adress)) {
                        char sendMessage[1000];
                        strcpy(sendMessage, "E-mail scheduled to be sent from on ");
                        strcat(sendMessage, extractMonth($2.date));
                        strcat(sendMessage, ", ");
                        strcat(sendMessage, extractYear($2.date));
                        strcat(sendMessage, ", ");
                        strcat(sendMessage, $2.time);
                        strcat(sendMessage, " to ");
                        strcat(sendMessage, receiver);
                        strcat(sendMessage, ": ");
                        strcat(sendMessage, "\"");
                        strcat(sendMessage, message);
                        strcat(sendMessage, "\"");
                        schedulePrints[schedulePrintIndex].message = strdup(sendMessage);
                        schedulePrints[schedulePrintIndex].date = strdup($2.date);
                        schedulePrints[schedulePrintIndex].time = strdup($2.time);
                        schedulePrintIndex++;
                        alreadySent[alreadySentIndex] = $2.sendStatementList[i].recipientList[k].adress;
                        alreadySentIndex++;
                      }
                    }
                  }
                }
              }
;

sendStatements : sendStatement{
                 $$.sendStatementList = (SendStatementNode*)malloc(100 * sizeof(SendStatementNode));
                 $$.sendStatementList[0] = $1;
                 $$.sendStatementListSize = 1;
               }
               | sendStatements sendStatement {
                 $$.sendStatementList = $1.sendStatementList;
                 $$.sendStatementListSize = $1.sendStatementListSize;
                 $$.sendStatementList[$$.sendStatementListSize] = $2;
                ($$.sendStatementListSize)++;
               }
;

sendStatement : tSEND tLBR tSTRING tRBR tTO tLBR recipientList tRBR{
                $$.string = strdup($3.value);
                $$.ident = "None";
                $$.recipientList = $7.recipientList;
                $$.recipientListSize = $7.recipientListSize; 
              }
              | tSEND tLBR tIDENT tRBR tTO tLBR recipientList tRBR{
                $$.ident = strdup($3.identName);
                $$.string = "None";
                $$.recipientList = $7.recipientList;
                $$.recipientListSize = $7.recipientListSize;
                $$.linenum = $3.linenum;
              }
;

recipientList : recipient{
                $$.recipientList = (RecipientNode*)malloc(100 * sizeof(RecipientNode));
                $$.recipientList[0].adress = strdup($1.adress);

                if($1.string){
                  ($$.recipientList)[0].string = strdup($1.string);
                }
                else{
                  ($$.recipientList)[0].string = "None";
                }

                if($1.ident){
                ($$.recipientList)[0].ident = strdup($1.ident);
                }
                else{
                  ($$.recipientList)[0].ident = "None";
                }

                $$.recipientList[0].linenum = $1.linenum;
                $$.recipientListSize = 1;
              }
              | recipientList tCOMMA recipient{
                $$.recipientList = $1.recipientList;
                $$.recipientListSize = $1.recipientListSize;
                ($$.recipientList)[$$.recipientListSize].adress = strdup($3.adress);

                if($3.string){
                  ($$.recipientList)[$$.recipientListSize].string = strdup($3.string);
                }

                if($3.ident){
                ($$.recipientList)[$$.recipientListSize].ident = strdup($3.ident);
                }

                $$.recipientList[$$.recipientListSize].linenum = $3.linenum;
                ($$.recipientListSize)++;
              }
;

recipient : tLPR tADDRESS tRPR{
            $$.adress = strdup($2.value);
            $$.string = "None";
            $$.ident = "None";
            $$.linenum = 0; //Impossible for uninitiliazed ident
          }
          | tLPR tSTRING tCOMMA tADDRESS tRPR{
            $$.adress = strdup($4.value);
            $$.string = strdup($2.value);
            $$.ident = "None";
            $$.linenum = 0; //Impossible for uninitiliazed ident
          }
          | tLPR tIDENT tCOMMA tADDRESS tRPR{
            $$.adress = strdup($4.value);
            $$.ident = strdup($2.identName);
            $$.string = "None";
            $$.linenum = $2.linenum;
          }
;
scheduleStatement : tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON sendStatements tENDSCHEDULE{
                    $$.sendStatementList = $9.sendStatementList;
                    $$.sendStatementListSize = $9.sendStatementListSize;
                    $$.date = $4.date;
                    $$.time = $6.time;
                    $$.linenum = $4.linenum;
                    }
;

setStatement : tSET tIDENT tLPR tSTRING tRPR{
                $$ = (SetStatementNode*)malloc(sizeof(SetStatementNode));
                $$->setStatementIdentName = strdup($2.identName);          
                $$->setStatementIdentValue = strdup($4.value);
              }
;

%%

int searchVariableList(IdentNode variableList[], int size, char *variable){
    int i = size - 1;
    for(; i >= 0; i--){
      if(strcmp(variableList[i].identName, variable) == 0){
        return i;
      }
    }
    return -1;
}

void printVariableList(IdentNode variableList[], int size){
  int i = 0;
  for(; i < size; i++){
    printf("Ident: %s Value: %s\n", variableList[i].identName, variableList[i].identValue);
  }
}

void printRecipientNodes(RecipientNode* array, int size) {
    int i = 0;
    for (; i < size; ++i) {
        printf("RecipientNode %d:\n", i + 1);
        printf("Address: %s\n", array[i].adress);

        if (array[i].string != NULL) {
            printf("String: %s\n", array[i].string);
        } else {
            printf("String: (null)\n");
        }

        if (array[i].ident != NULL) {
            printf("Ident: %s\n", array[i].ident);
        } else {
            printf("Ident: (null)\n");
        }

        //printf("\n");
    }
}

int isValuePresent(char** array, int arraySize, char* value) {
    int i = 0;
    for (; i < arraySize; ++i) {
        if (strcmp(array[i], value) == 0) {
            return 1;  // Value found
        }
    }
    return 0;  // Value not found
}

void addPrefixToStrings(char** strings, size_t size, int previous, char* prefix) {
    size_t i = previous;
    for (; i < size; ++i) {
        // Calculate the length of the new string
        size_t newLength = strlen(prefix) + strlen(strings[i]) + 1;

        // Allocate memory for the new string
        char* newString = (char*)malloc(newLength);

        // Copy the prefix and the original string into the new string
        strcpy(newString, prefix);
        strcat(newString, strings[i]);

        // Update the original string with the new string
        strings[i] = newString;
    }
}

void printCharArray(char** array, int size) {
    int i = 0;
    for (; i < size; ++i) {
        printf("%s\n", array[i]);
    }
}

int comparePrints(const void *a, const void *b) {
    const ScheduleStatementPrint *printA = (const ScheduleStatementPrint *)a;
    const ScheduleStatementPrint *printB = (const ScheduleStatementPrint *)b;

    // Compare years
    int yearComparison = strcmp(printA->date + 6, printB->date + 6);
    if (yearComparison != 0) {
        return yearComparison;
    }

    // Compare months
    int monthComparison = strcmp(printA->date + 3, printB->date + 3);
    if (monthComparison != 0) {
        return monthComparison;
    }

    // Compare days
    int dayComparison = strcmp(printA->date, printB->date);
    if (dayComparison != 0) {
        return dayComparison;
    }

    // Dates are the same, compare times
    int timeComparison = strcmp(printA->time, printB->time);
    if (timeComparison != 0) {
        return timeComparison;
    }

    // Dates and times are the same, compare indices
    return 0;
}

void sortScheduledPrints(ScheduleStatementPrint scheduledPrints[], int size) {
    qsort(scheduledPrints, size, sizeof(ScheduleStatementPrint), comparePrints);
}

int isLeapYear(int year) {
    return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0));
}

int isValidDate(char* date) {
    int day, month, year;
    char separator;
    
    // Check for the possible separators
    if (sscanf(date, "%d%c%d%c%d", &day, &separator, &month, &separator, &year) != 5) {
        return 1; // Incorrect format
    }

    // Check if the separator is valid
    if (separator != '/' && separator != '-' && separator != '.') {
        return 1; // Invalid separator
    }

    if (year < 1 || month < 1 || month > 12 || day < 1) {
        return 1; // Invalid values
    }

    int daysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    if (month == 2 && isLeapYear(year)) {
        daysInMonth[2] = 29; // Update days in February for leap years
    }

    if (day > daysInMonth[month]) {
        return 1; // Invalid day for the given month
    }

    return 0; // Valid date
}

int isValidTime(char* time) {
    int hours, minutes;
    if (sscanf(time, "%d:%d", &hours, &minutes) != 2) {
        return 1; // Incorrect format
    }

    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return 1; // Invalid values
    }

    return 0; // Valid time
}

char* extractMonth(char* date) {
    char* months[] = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

    int day, month, year;
    sscanf(date, "%d%*[-/.]%d%*[-/.]%d", &day, &month, &year);

    char* formattedMonth = (char*)malloc(strlen(months[month - 1]) + 3); // +3 for the space and day
    sprintf(formattedMonth, "%s %d", months[month - 1], day);

    return formattedMonth;
}

// Function to extract and format the year
char* extractYear(char* date) {
    int day, month, year;
    sscanf(date, "%d%*[-/.]%d%*[-/.]%d", &day, &month, &year);

    char* formattedYear = (char*)malloc(5); // Assuming a 4-digit year
    sprintf(formattedYear, "%d", year);

    return formattedYear;
}

void printScheduleMessages(ScheduleStatementPrint schedule[], int size) {
    int i = 0;
    for (; i < size; ++i) {
        printf("%s\n", schedule[i].message);
    }
}

void addStringToMessage(ScheduleStatementPrint array[], int size, int previous, char* stringToBeAdded) {
    int i = previous;
    for (; i < size; ++i) {
        // Calculate the new size for the modified message
        size_t newSize = strlen(array[i].message) + strlen(stringToBeAdded) + 1;

        // Allocate memory for the new message
        char *newMessage = (char *)malloc(newSize);

        // Copy the original message up to position 33
        strncpy(newMessage, array[i].message, 33);

        // Add the stringToBeAdded
        strcat(newMessage, stringToBeAdded);

        // Copy the rest of the original message
        strcat(newMessage, array[i].message + 33);

        // Update the message in the struct
        array[i].message = newMessage;
    }
}

int main () 
{
    errors = (char**)malloc(1000 * sizeof(char*));
    sendPrints = (char**)malloc(1000 * sizeof(char*));

   if (yyparse())
   {
      printf("ERROR\n");
      return 1;
    } 
    else 
    {
      if(error == 0){
        printCharArray(sendPrints, sendPrintIndex);
        sortScheduledPrints(schedulePrints, schedulePrintIndex);
        printScheduleMessages(schedulePrints, schedulePrintIndex);  
        }
      else{
        printCharArray(errors, errorIndex);
      }           
      return 0;
    } 
}