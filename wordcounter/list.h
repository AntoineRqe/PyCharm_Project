#ifndef LIST_H
#define LIST_H
/* Functions and structures related to chained list */

typedef struct Element Element;
typedef struct List List;

struct Element{
    char* word;
    struct Element* next;
};

struct List{
    struct Element* head;
};

List *initialisation(void);
void insert(List* list, char* word_to_add, int size);
unsigned int count(Element* start);
void print_list(Element* start);
void liberate(List * list);
void compare_list(Element* dict_list, Element* text_list);

/* --------------------------------------------------------------------------------
 *                                      Tests
 * ------------------------------------------------------------------------------ */
void test_chained_list(void);

#endif //LIST_H
