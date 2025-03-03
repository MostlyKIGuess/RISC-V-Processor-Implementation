addi x1, x0, 15    
addi x2, x0, 25    
addi x3, x0, 7     
addi x4, x0, 18    
add x5, x1, x2     
sub x6, x2, x1     
and x7, x1, x3     
or x8, x1, x3      
sd x5, 0(x0)       
sd x6, 8(x0)       
ld x9, 0(x0)       
ld x10, 8(x0)      
add x11, x9, x10   
sub x12, x9, x10   
beq x11, x12, skip 
addi x13, x0, 100  
or x14, x11, x12   
and x15, x11, x12  
sd x14, 16(x0)     
sd x15, 24(x0)     
skip:
addi x16, x0, 50   
add x17, x16, x15  
sub x18, x17, x14  
beq x17, x18, end  
ld x19, 16(x0)     
ld x20, 24(x0)     
or x21, x19, x20   
and x22, x19, x20  
sd x21, 32(x0)     
sd x22, 40(x0)     
end:
nop
