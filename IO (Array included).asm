.MODEL SMALL 
.STACK 100H 
.DATA

CR EQU 13
LF EQU 10      
N DW ?
NUMBER_STRING DB '00000$'  
NEGATIVE DW 0

ARR1 DW 100 DUP(0)
ARR2 DW 100 DUP(0)   

SIZE DW 0
SIZE1 DW 0
SIZE2 DW 0 
TEMP DW 0 
INP_OVER DW 0

             
.CODE 
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX  
               
    ; INPUT ARRAY 1
    LEA SI, ARR1
    MOV INP_OVER, 0
    MOV SIZE, 0
    CALL INP_ARR
    MOV BX, SIZE
    MOV SIZE1, BX
    MOV INP_OVER, 0
                   
                   
    ; INPUT ARRAY 2
    LEA SI, ARR2
    MOV INP_OVER, 0
    MOV SIZE, 0 
    CALL INP_ARR
    MOV BX, SIZE
    MOV SIZE2, BX
    MOV INP_OVER, 0 
    
       
    ; PRINT ARRAY 1
    LEA DI, ARR1
    MOV BX, SIZE1
    MOV SIZE, BX 
    CALL PRINT_ARR
                   
                   
    ; PRINT ARRAY 2
    LEA DI, ARR2
    MOV BX, SIZE2
    MOV SIZE, BX 
    CALL PRINT_ARR
         
    
    ; INTERRUPT TO EXIT
    MOV AH, 4CH
    INT 21H
MAIN ENDP       
         
         

; TAKES AN ARRAY INPUT IN SI, STORES LENGTH IN SIZE
INP_ARR PROC
    PUSH SI
    PUSH BX
    LOOP1:
        CALL INPUT  
        MOV [SI], BX
        ADD SI, 2
        INC SIZE    
        CMP INP_OVER, 1
        JE HERE
        JMP LOOP1    
        
    HERE:
        CALL NEWLINE
        POP BX
        POP SI     
        RET
ENDP INP_ARR                               



; PRINTS THE ARRAY IN DI, STORE THE LENGTH IN SIZE
PRINT_ARR PROC
    PUSH AX
    PUSH DI
    PUSH BX 
    MOV TEMP, 0
    LOOP2:        
        MOV AX, [DI] 
        CALL PRINT 
        CALL SPACE
        ADD DI, 2
        INC TEMP 
        MOV BX, SIZE
        CMP BX, TEMP
        JG LOOP2
                    
    CALL NEWLINE
    POP BX
    POP DI
    POP AX
    RET
ENDP PRINT_ARR
       
       
          
; TAKE AN INPUT IN BX, ALSO MOVES THE NUMBER TO N
; NEGATIVE WILL BE 1 IF THE INPUT IS NEGATIVE 

; OF COURSE USE N TO RETRIEVE THE NUMBER LATER
; AS AX CAN BE ALTERED IN DIFFERENT WAYS         
INPUT PROC 
;    PUSH BX
;    PUSH AX
;    PUSH CX  
    XOR BX, BX ; CLEAR BX      
    MOV NEGATIVE, 0
    MOV AH, 1
    INT 21H        
         
    ; CHECK IF THE FIRST CHARACTER IS \n or \r         
    CMP AL, ' '
    JE END_INPUT_LOOP
    CMP AL, CR  
    JE INPUT_OVER
    CMP AL, LF
    JE INPUT_OVER
        
    
    CMP AL, '-'
    JE MARK_NEG
    ; SO ALREADY TOOK THE FIRST DIGIT AS INPUT
    ; HAVE TO PROCESS THAT, THEN GO THE LOOP FOR THE REST
    AND AX, 000FH ; fast char to digit, also clears AH
    ; save AX 
    MOV CX, AX
    ; BX = BX * 10 + AX
    MOV AX, 10
    MUL BX
    ADD AX, CX
    MOV BX, AX
    JMP INPUT_LOOP
    
    MARK_NEG:
        MOV NEGATIVE, 1 ; REMEMBER TO FINALLY NEGATE THE NUMBER
    
    INPUT_LOOP: 
        ; char input 
        MOV AH, 1
        INT 21H
        
        ; CHECK IF THE FIRST DIGIT IS \n or \r         
        CMP AL, ' '
        JE END_INPUT_LOOP
        CMP AL, CR  
        JE INPUT_OVER
        CMP AL, LF
        JE INPUT_OVER
        
        ; fast char to digit
        ; also clears AH
        AND AX, 000FH
        
        ; save AX 
        MOV CX, AX
        
        ; BX = BX * 10 + AX
        MOV AX, 10
        MUL BX
        ADD AX, CX
        MOV BX, AX
        JMP INPUT_LOOP 
        
    INPUT_OVER:
        MOV INP_OVER, 1
    
    END_INPUT_LOOP:
        CMP NEGATIVE, 1
        JNE END_ALL
        NEG BX
        
    END_ALL:  
        MOV N, BX
;        POP CX
;        POP AX
;        POP BX 
        RET        
INPUT ENDP
    

      
      
; THE NUMBER TO BE PRINTED IS STORED IN AX
; THIS IS ALSO BENEFICIAL AS THE DIVIDEND
; HAS TO BE STORED IN DX:AX               
; OF COURSE MAKE SURE TO MOVE THE DESIRED
; NUMBER TO AX IMMEDIATELY BEFORE CALLING THIS FUNCTION
; AS AX CAN OTHERWISE BE ALTERED   
PRINT PROC
    PUSH SI
    PUSH AX    
    PUSH BX
    PUSH CX
    PUSH DX         
    LEA SI, NUMBER_STRING
    ADD SI, 5
    
    ; FIRST CHECK IF THE NUMBER IN AX IS NEGATIVE
    MOV BX, 1
    SHL BX, 15 ; NOW BX IS 2^15
    TEST AX, BX
    ; IF THE SIGN BIT OF AX IS 1, THEN JZ WILL NOT GET EXECUTED 
    JZ PRINT_LOOP
    ; OTHERWISE THE NUMBER IS NEGATIVE
    MOV BX, 1
    NEG AX
    
    
    PRINT_LOOP:
        DEC SI
        MOV DX, 0
        ; DX:AX = 0000:AX
        MOV CX, 10
        DIV CX
        ADD DL, '0'
        MOV [SI], DL
        CMP AX, 0
        JNE PRINT_LOOP 
        
    CMP BX, 1
    JNE DO_PRINT_NUMBER
    MOV DL, '-'
    MOV AH, 2
    INT 21H
                
    DO_PRINT_NUMBER:
        MOV DX, SI
        MOV AH, 09
        INT 21H
           
    POP DX
    POP CX    
    POP BX
    POP AX
    POP SI
    RET

PRINT ENDP
          
          
       
       
; CALL THE NEWLINE FUNCTION TO PRINT A NEWLINE ANYWHERE             
NEWLINE PROC 
    PUSH AX
    PUSH DX
    MOV AH, 2
    MOV DL, CR
    INT 21H
    MOV DL, LF
    INT 21H
    POP DX
    POP AX
    RET
NEWLINE ENDP              
         
         
         
         
; CALL THE SPACE FUNCTION TO PRINT A SPACE ANYWHERE             
SPACE PROC 
    PUSH AX
    PUSH DX
    MOV AH, 2
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
SPACE ENDP

           
       
           
END MAIN 