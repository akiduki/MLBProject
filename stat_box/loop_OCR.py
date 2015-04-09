# Chenge Li cl2840@nyu.edu
import os, sys
os.chdir('/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/matching_box/')
import types
import Image
import glob
import pdb
sys.path.append('/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/')
import pytesseract


# text_file = open("/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/Name_red.txt", "wb")
# text_file = open("/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/Name_blue.txt", "wb")
text_file=open("/Users/Chenge/Documents/github/inProgress/Name_match_first.txt",'wb')
for filename in glob.glob("*.png"):
    im=Image.open(filename)
#     print pytesseract.image_to_string(im, lang='eng')
    name=pytesseract.image_to_string(im, lang='eng')
    name_first_part=""
    for i in name:
        if ord(i)!=10:
            name_first_part=name_first_part+i;
        if ord(i)==10: 
        	break
        # pdb.set_trace()
#     isinstance(name, str)
    text_file.write("%s\n\n"%(filename[0:8]+'  '+name_first_part))
    # pdb.set_trace()
text_file.close()



