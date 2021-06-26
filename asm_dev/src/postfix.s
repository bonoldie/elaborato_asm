# Funzione `postfix`      
# effettua la computazione di una stringa in RPN e ne ritorna il risultato

# ########## #
#    DATA    #
# ########## #

.section .data

# char operatori
char_add:
    .ascii "+"
char_sub: 
    .ascii "-"
char_mul:
    .ascii "*" 
char_div: 
    .ascii "/"

# char speciali
char_spazio:
    .ascii " "
char_fine: 
    .ascii "\0"

# flags operazioni
flag_add:
    .byte 0x1
flag_sub:
    .byte 0x2
flag_mul:
    .byte 0x4
flag_div:
    .byte 0x8

# flag fine
flag_fine:
    .byte 0x1

flag_fine_operazione:
    .byte 0x2

flag_neg:
    .byte 0x3


# invalid rpn
string_invalid: 
    .ascii "Invalid\0"

# ######## #
#   CODE   #
# ######## #

# `flag_operazione` = 0 (cl)

.section .text
    .global postfix

postfix:

    # ######## #
    #  SETUP   #
    # ######## #
    xorl %ebx,%ebx
    xorl %ecx,%ecx

    # flag_fine_operazione primo numero
    mov $0x2,%ch
 
    movl 4(%esp),%eax

    # salvo stack pointer in modo da poter effettuare un controllo a 
    # fine programma
    movl %esp,%esi

    # ######## #
    #  WHILE   #
    # ######## #

    # leggo un nuovo carattere
    leggi_carattere:
        # cleanup
        xorl %edx,%edx
        xorl %ebx,%ebx
    
        # carico il carattere in %dh
        mov (%eax),%dh
        inc %eax
        
        # controllo caso: operazione
        
        # controllo segno "+"
        leal char_add,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_add

        # controllo segno "-"
        leal char_sub,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_sub
        
        # controllo segno "*"
        leal char_mul,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_mul
        
        # controllo segno "/"
        leal char_div,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_div
        

        # controllo caso: " " oppure "\0"

        # controllo carattere " "
        leal char_spazio,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_spazio

        # controllo carattere "\0"
        leal char_fine,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_fine

        # controllo caso: cifra

        # offset cifre codifica ascii
        mov $0x30,%dl

        # %dh contiene il valore atoi del carattere (in complemento a 2)
        sub %dl,%dh
        # se l'operazione ritorna un valore negativo allora non è una cifra ascii
        js pulisci_stack

        cmp $9,%dh
        # se il numero è maggiore della cifra 9 allora non è una cifra ascii
        jg pulisci_stack

        # %edx contiene il valore della cifra 
        mov %dh,%dl
        mov $0,%dh

        # se %ch è a flag_fine_operazione allora inizio un nuovo numero
        cmp $0x2,%ch
        jnz accumulo_cifra

    prima_cifra:
        movl $0,%ebx
        # controllo flag_sub nel caso di prima cifra numero negativo   
        cmp $0x2,%cl
        jz prima_cifra_negativa
    
    prima_cifra_positiva:
        mov $0,%ch
        mov %dl,%bl
        pushl %ebx
        jmp leggi_carattere

    prima_cifra_negativa:
        mov $0x3,%ch
        mov $0x0,%cl

        mov %edx,%ebx
        
        neg %ebx 

        pushl %ebx
        jmp leggi_carattere

    accumulo_cifra:
        popl %ebx
        imul $10,%ebx,%ebx

        # controllo flag_neg nel caso di accumulo numero negativo   
        cmp $0x3,%ch
        jz accumulo_cifra_negativa

    accumulo_cifra_positiva:
        addl %edx,%ebx
        pushl %ebx
        jmp leggi_carattere

    accumulo_cifra_negativa:
        mov $0x3,%ch

        subl %edx,%ebx
        pushl %ebx
        jmp leggi_carattere

    # ########## #
    #    FLAG    #
    # ########## #

    # set dei flag nel caso il carattere sia un segno
    caso_add:
        leal flag_add,%edx
        mov (%edx),%cl
        jmp leggi_carattere
    caso_sub:
        leal flag_sub,%edx
        mov (%edx),%cl
        jmp leggi_carattere
    
    caso_mul:
        leal flag_mul,%edx
        mov (%edx),%cl
        jmp leggi_carattere

    caso_div:
        leal flag_div,%edx
        mov (%edx),%cl
        jmp leggi_carattere

    # ############ #
    #  OPERAZIONI  #
    # ############ #

    caso_fine:
        mov $0x1,%ch
        jmp inizio_operazioni

    # caso spazio o '\0'
    caso_spazio:
        # set flag di fine operazione per l'aggiunta di un eventuale nuovo numero
        mov $0x2,%ch
        
    inizio_operazioni: 
        leal flag_add,%ebx
        mov (%ebx),%dl
        cmp %dl,%cl
        jz exec_add

        leal flag_sub,%ebx
        mov (%ebx),%dl
        cmp %dl,%cl
        jz exec_sub
        
        leal flag_mul,%ebx
        mov (%ebx),%dl
        cmp %dl,%cl
        jz exec_mul

        leal flag_div,%ebx
        mov (%ebx),%dl
        cmp %dl,%cl
        jz exec_div


    # dopo aver eseguito ogni operazione faccio un push
    post_operazione:
        mov $0x0,%cl

        # se in %cx h1o  vuol dire che ho finito
        cmp $0x1,%ch
        jz set_risultato

        jmp leggi_carattere


    exec_add:
        popl %ebx
        popl %edx
        addl %edx,%ebx
        pushl %ebx
        jmp post_operazione
    
    exec_sub:
        popl %ebx
        popl %edx
        subl %ebx,%edx
        pushl %edx
        jmp post_operazione

    exec_mul:
        popl %ebx
        popl %edx
        imull %ebx,%edx
        pushl %edx
        jmp post_operazione

    exec_div:
        popl %ebx
        popl %edx 
        
        # mi serve %eax per la divisione 
        pushl %eax
        
        # setup per idiv
        movl %edx,%eax
        cdq

        idiv %ebx

        # restore di %eax e salvataggio del risultato
        popl %ebx
        pushl %eax
        movl %ebx,%eax
        
        jmp post_operazione

        
    # ######## #
    #   FINE   #
    # ######## #

    set_risultato:
        # il risultato è in %edx
        popl %edx

        # riporto lo stack allo stato originale
        movl %esi,%esp

        # puntatore alla stringa di output
        movl 8(%esp),%edi
        
        # setup per atoi 
        xorl %ecx,%ecx
        movl %edx,%eax  
        movl $0xA,%ebx
        
        # nel caso di numero negativo aggiungo il segno 
        cmpl $0,%eax
        jge atoi_loop

        movb $45,(%edi)
        inc %edi
        neg %eax

    atoi_loop:
        # convert eax (dword) in edx:eax (qword) 
        cdq  
        
        idiv %ebx   
              
        # codifica in ascii della cifra
        add $48,%dl
        push %dx
        inc %ecx

        cmpl $0x0,%eax
        jnz atoi_loop
    
    set_output:
        
        pop %dx
        mov %dl,(%edi)
        inc %edi
        dec %ecx
        jnz set_output

        # Aggiungo il carattere di fine stringa
        movb $0,(%edi)
        jmp end
        
    pulisci_stack:
        movl %esi,%esp

    set_invalid_rpn:
        # sono allo stato iniziale dello stack
        # puntatore alla stringa di output
        movl 8(%esp),%eax
        # scrivo la striga 
        leal string_invalid,%ebx
        movl (%ebx),%ecx
        movl %ecx,(%eax)

        movl 4(%ebx),%ecx
        movl %ecx,4(%eax)

    end:
        ret


