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
    .byte 0x1E

# invalid rpn
string_invalid: 
    .ascii "Invalid\0"

# ######## #
#   CODE   #
# ######## #

# `char pointer` punta al primo carattere (eax)
# `accumulatore` = 0 (ebx)
# `flag_operazione` = 0 (cl)
# `cifra_carattere` = 0 (edx)

.section .text
    .global postfix

postfix:
    # ######## #
    #  SETUP   #
    # ######## #

    # `char pointer` 
    movl 4(%esp),%eax

    # bottom dello stack
    pushl $0xFFFFFFFF

    pushl $1238757

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


