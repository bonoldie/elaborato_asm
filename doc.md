__________________________
|3|0| |2| |+| |2|0| |-|\0|

variabili:
    `char pointer` : (char pointer)
    `accumulatore` : (signed int)
    `flag_operazione`: (byte 0x1/add 0x2/sub 0x4/mul 0x8/div)
    `cifra_carattere` : (long)

setup:
    `char pointer` punta al primo carattere (eax)
    `accumulatore` = 0 (ebx)
    `flag_operazione` = 0 (cl)
    `cifra_carattere` = 0 (edx)

1. controllo il valore puntato da `char pointer`
2. caso: *`char pointer` == cifra
    2.1. `cifra_carattere` = atoi(*`char pointer`) 
    2.2. accumulatore = accumulatore * 10
    2.3. caso: `flag_operazione` == 0x2
        # ho un numero negativo #
        2.2.1 accumulatore = accumulatore - cifra_carattere   
    2.4. caso: `flag_operazione` != 0x2
        # ho un numero positivo #
        2.2.1 accumulatore = accumulatore + cifra_carattere
    2.5. torno a 1.   
3. caso: *`char pointer` == operatore(+-*/)
    3.1 `flag_operazione` = 0x1/add 0x2/sub 0x4/mul 0x8/div
    3.2 torno a 1.
4. caso: *`char pointer` == spazio oppure *`char pointer` == \0  
    5.1 caso: `accumulatore` != 0
        5.1.1. push `accumulatore`
        5.1.2. `accumulatore` = 0
        5.1.3. torno a 1.
    5.2. pop primo operando
    5.3. pop secondo operando
    5.4. operazione in base al flag tra i due operandi
    5.5. push del risultato
    5.6. caso: *`char pointer` == \0
        5.6.1 pop risultato 
        5.6.2 risultato = itoa(risultato)
        5.6.3 scrivo il risultato e ritorno
    5.7. `flag_operazione` = 0x0
    5.7. torno a 1.
5. caso: nessuno dei precedenti 
    6.1. scrivo `Invalid` come risultato e ritorno
            

