.386                       ;directive  indiquant qu'il s'agit du prossesseur 80386
.model flat, stdcall       ;directive inconu
option casemap : none      ;directive indiquant qu'il faut faire la diff�rence entre les majuscules et les minuscules

include \masm32\include\masm32rt.inc     ;encore une directive inconnu


.code          ;d�but du code


salut :

print "contenu de ch : "

mov ch, 40



   movzx eax, ch 
   print str$ (eax) 
    
print " ", 13, 10 
print "contenu de cl : "
mov cl, 35



   movzx eax, cl 
   print str$ (eax) 

print " ", 13, 10

 inkey "Appuyez sur une touche pour continuer..."
 exit  
 
end salut