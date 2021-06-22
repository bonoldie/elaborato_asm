# Funzione `postfix`      
# effettua la computazione di una stringa in RPN e ne ritorna il risultato
 
.section .data


invalid: 
    .ascii "Invalid\0"

# Per ogni operazione creo un flag di riconoscimento
o_som: 
    .ascii "\0\0\0+"
f_som:
    .byte 0b00000001

o_sot: 
    .ascii "\0\0\0-"
f_sot:
    .byte 0b00000010

o_mol: 
    .ascii "\0\0\0*"
f_mol:
    .byte 0b00000100

o_div: 
    .ascii "\0\0\0/"
f_div:
    .byte 0b0001000

o_spa: 
    .ascii "\0\0\0 "


# Offset dei caratteri delle cifre nella codifica ascii
ascii_offset_cifre: 
    .long 0x0000001E

# Entry del programma
.section .text
    .global postfix

# Funzione postfix
postfix:
    # puntatore a input
    movl 4(%esp),%eax
    
    movl $0,%ebx

    movl $0,%ecx

    # flag operazione
    movl $0,%edx

    # carica un nuovo valore dalla stringa di input
    carica_valore:
    movl $0,%ebx
    movb (%eax),%bl

    # caso: spazio
    # devo gestirlo per primo 
    cmpl %ebx,o_spa
    jz gestisci_spazio


    # caso: operazione
    cmpl %ebx,o_som

    cmpl %ebx,o_sot
    
    cmpl %ebx,o_mol
    
    cmpl %ebx,o_div
    





    # caso: cifra
    # cmpl %ebx,$0x0000000 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000001 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000002 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000003 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000004 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000005 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000006 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000007 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000008 + ascii_offset_cifre
    # jz carica_cifra
    # cmpl %ebx,$0x0000009 + ascii_offset_cifre
    # jz carica_cifra

    # caso: carattere invalido
    jmp invalid_input


    # ##########################################################
    gestisci_spazio:
    # salvo valore nello stack e carico un nuovo carattere
    push %ecx
    movl $0,%ecx
    jmp carica_valore

    
    # imposta il flag di operazione somma
    set_som:
    leal f_som,%edx
    movb (%edx),%dl
    jmp carica_valore
    # imposta il flag di operazione sottrazione
    set_sot:
    leal f_sot,%edx
    movb (%edx),%dl
    jmp carica_valore
    # imposta il flag di operazione moltiplicazione
    set_mol:
    leal f_mol,%edx
    movb (%edx),%dl
    jmp carica_valore
    # imposta il flag di operazione divisione
    set_div:
    leal f_div,%edx
    movb (%edx),%dl
    jmp carica_valore

    # effettua l'operazione di somma
    do_som:
    jmp carica_valore
    
    # effettua l'operazione di sottrazione
    do_sot:
    jmp carica_valore
    
    # effettua l'operazione di moltiplicazione
    do_mol:
    jmp carica_valore
    
    # effettua l'operazione di divisione
    do_div:
    jmp carica_valore

    # una cifra è stata riconosciuta e viene aggiunta ad %ecx
    carica_cifra:   
    jmp carica_valore

    # scrive `Invalid` in output
    invalid_input:
    # puntatore a input
    movl 4(%esp),%eax
    # puntatore a output
    movl 8(%esp),%ebx    

    # calcolo indirizzo e scrittura in output
    leal invalid,%edx
    
    movl (%edx),%ecx
    movl %ecx,(%ebx)

    movl 4(%edx),%ecx
    movl %ecx,4(%ebx)

    # ritorna alla funzione main
    ret
    