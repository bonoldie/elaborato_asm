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

# offset cifre ascii
offset_cifre_ascii:
    .byte 0x30

# invalid rpn
string_invalid: 
    .ascii "Invalid\0"

# ######## #
#   CODE   #
# ######## #

# `char pointer` punta al primo carattere (eax)
# `accumulatore` = 0 (ebx)
# `flag_operazione` = 0 (cl)
# `cifra_carattere`(temp var) = 0 (edx)

.section .text
    .global postfix

postfix:

    # ######## #
    #  SETUP   #
    # ######## #
    xorl %ebx,%ebx
    xorl %ecx,%ecx

    # `char pointer` 
    movl 4(%esp),%eax

    # delimitatore dello stack
    pushl $0xFFFFFFFF

    # primo numero
    pushl $0x0

    # ######## #
    #  WHILE   #
    # ######## #

    # leggo un nuovo carattere
    leggi_carattere:
        # cleanup
        xorl %edx,%edx
        xorl %ebx,%ebx
    
        mov (%eax),%dh
        addl $1,%eax
        
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
        
        # controllo caso: *`char pointer` == cifra
        leal offset_cifre_ascii,%ebx
        mov (%ebx),%dl

        # %dh contiene il valore atoi del carattere (in complemento a 2)
        sub %dl,%dh
        # se l'operazione ritorna un valore negativo allora non è una cifra ascii
        js set_invalid_rpn

        cmp $9,%dh
        # se il numero è maggiore della cifra 9 allora non è una cifra ascii
        jg set_invalid_rpn

        # controllo caso: spazio oppure \0

        # controllo carattere " "
        leal char_spazio,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_spazio_fine

        # controllo carattere "\0"
        leal char_fine,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_spazio_fine

    caso_cifra:

        popl %ebx
        imul $10,%ebx,%ebx
        # controllo flag_sub che denota un numero negativo

        cmp $0x2,%cl
        jz cifra_positiva

    cifra_negativa:
        sub %dh,%al
        pushl %ebx
        jmp leggi_carattere
       
    cifra_positiva:
        add %dh,%bl
        pushl %ebx
        jmp leggi_carattere




    # ########## #
    #    FLAG    #
    # ########## #

    # set dei flag nel caso il carattere sia un segno
    caso_add:
        leal flag_add,%ecx
        mov (%ecx),%cl
        jmp leggi_carattere
   
    caso_sub:
        leal flag_sub,%ecx
        mov (%ecx),%cl
        jmp leggi_carattere
    
    caso_mul:
        leal flag_mul,%ecx
        mov (%ecx),%cl
        jmp leggi_carattere

    caso_div:
        leal flag_div,%ecx
        mov (%ecx),%cl
        jmp leggi_carattere

    # ############ #
    #  OPERAZIONI  #
    # ############ #

    caso_spazio_fine:
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
        

        # controllo carattere "\0"
        leal char_fine,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        jz caso_spazio_fine

        # controllo carattere " "
        leal char_spazio,%ebx
        mov (%ebx),%dl
        cmp %dl,%dh
        

        



    exec_add:
        popl %ebx
        popl %edx
        addl %edx,%ebx
        pushl %ebx
        jmp leggi_carattere
    exec_sub:
        popl %ebx
        popl %edx
        subl %ebx,%edx
        pushl %edx
        jmp leggi_carattere
    exec_mul:
        popl %ebx
        popl %edx
        imull %ebx,%edx
        pushl %ebx
        jmp leggi_carattere

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
        movl %ebx,%ebx

        jmp leggi_carattere
        
    # ######## #
    #   FINE   #
    # ######## #

    set_risultato:
        # il risultato è in %edx
        popl %edx
        
        # se trovo 0xFFFFFFFF vuol dire che ho non ho il risultato nello stack
        cmpl $0xFFFFFFFF,%edx
        jz set_invalid_rpn

        # se non trovo 0xFFFFFFFF vuol dire che ho operandi ma non operazioni
        popl %eax
        cmpl $0xFFFFFFFF,%eax
        jnz pulisci_stack

        # puntatore alla stringa di output
        movl 8(%esp),%ecx
        
        # setup per atoi 
        movl %edx,%eax  
        movl $0xA,%ebx
        

        # nel caso di numero negativo aggiungo il segno 
        cmpl $0x0,%eax
        jge atoi_loop


        movb $45,(%ecx)
        addl $1,%ecx
        neg %eax

    atoi_loop:
        # convert eax (dword) in edx:eax (qword) 
        cdq  
        
        idiv %ebx   
              
        add $48,%dl
        mov %dl,(%ecx)
        addl $1,%ecx

        cmpl $0x0,%eax
        jnz atoi_loop

        # Aggiungo il carattere di fine stringa
        movb $0,(%ecx)
        jmp end
        
    pulisci_stack:
        popl %edx
        cmpl $0xFFFFFFFF,%edx
        jnz pulisci_stack

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


