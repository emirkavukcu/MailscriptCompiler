#ifndef _TYPES_
#define _TYPES_

typedef struct ScheduleStatementPrint {
    char *message;
    char *date;
    char *time;
} ScheduleStatementPrint;

typedef struct IdentNode
{
   char *identName;
   char *identValue;
   int linenum;
} IdentNode;

typedef struct StringNode
{
    char *value;
} StringNode;

typedef struct AdressNode
{
    char *value;
} AdressNode;

typedef struct SendTokenNode
{
    int linenum;
} SendTokenNode;

typedef struct DateNode
{
    char *date;
    int linenum;
} DateNode;

typedef struct TimeNode
{
    char *time;
} TimeNode;

typedef struct SetStatementNode
{
    char *setStatementIdentName;
    char *setStatementIdentValue;
} SetStatementNode;

typedef struct ProgramNode
{
} ProgramNode;

typedef struct StatementsNode
{
} StatementsNode;

typedef struct StatementListNode
{
    struct SendStatementNode *sendStatementList;
    int sendStatementListSize;
    struct ScheduleStatementNode *scheduleStatementList;
    int scheduleStatementListSize;
} StatementListNode;

typedef struct MailBlockNode
{
    struct ScheduleStatementNode *scheduleStatementList;
    int scheduleStatementListSize;
} MailBlockNode;

typedef struct SendStatementsNode
{
    struct SendStatementNode *sendStatementList;
    int sendStatementListSize;
} SendStatementsNode;

typedef struct SendStatementNode
{
    char *string;
    char *ident;
    struct RecipientNode *recipientList;
    int recipientListSize;
    int linenum;
} SendStatementNode;


typedef struct ScheduleStatementNode
{
    struct SendStatementNode *sendStatementList;
    int sendStatementListSize;
    char *date;
    char *time;
    int linenum;
} ScheduleStatementNode;

typedef struct RecipientNode
{
    char *adress;
    char *string;
    char *ident;
    int linenum;
} RecipientNode;

typedef struct RecipientListNode
{
    struct RecipientNode *recipientList;
    int recipientListSize;
} RecipientListNode;


#endif //_TYPES_