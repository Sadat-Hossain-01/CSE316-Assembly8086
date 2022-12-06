; A TERNARY NUMBER WILL BE GIVEN, MIGHT CONTAIN INVALID NUMBERS IN BETWEEN, IGNORE THEM
; STOP THE INPUT UPON PRESSED ENTER
; PRINT THE TERNARY NUMBER STARTING FROM LSB

.MODEL SMALL
.STACK 100H

.DATA  
N DW ?       
CR EQU 0DH
LF EQU 0AH


.CODE                                    
MAIN PROC                                
    MOV AX, @DATA
    MOV DS, AX                                                    
    
    ; fast BX = 0
    XOR BX, BX
    
    INPUT_LOOP:
        ; char input 
        MOV AH, 1
        INT 21H 
        
        ; if \n\r, stop taking input
        CMP AL, CR    
        JE END_INPUT_LOOP
        CMP AL, LF
        JE END_INPUT_LOOP          
        
        CMP AL, '0'
        JE PROCESS
        CMP AL, '1'
        JE PROCESS
        CMP AL, '2'
        JE PROCESS
        JMP INPUT_LOOP           
        
        PROCESS:
            ; fast char to digit
            ; also clears AH
            AND AX, 000FH
            
            ; save AX 
            MOV CX, AX
            
            ; BX = BX * 3 + AX
            MOV AX, 3
            MUL BX
            ADD AX, CX
            MOV BX, AX
            JMP INPUT_LOOP
    
    END_INPUT_LOOP:
        MOV N, BX 
        
    MOV CL, 2 ; NO NEED ANYMORE
    
    MOV BX, N 
              
    ; NEW LINE PRINTING
    MOV AH, 2
    MOV DL, CR
    INT 21H
    MOV DL, LF
    INT 21H   
    
    
    TLOOP:
        CMP BX, 0
        JE END_MAIN
        MOV CX, 1
        AND CX, BX
        SHR BX, 1
        MOV DL, CL 
        ADD DL, '0'
        MOV AH, 2
        INT 21H 
        JMP TLOOP
           

    END_MAIN:
        MOV AH, 4CH
        INT 21H ; INTERRUPT TO EXIT  
        
MAIN ENDP
END MAIN