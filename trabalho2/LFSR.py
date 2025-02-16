
str_bit :str = '10101010'

xor_truth_table = {
    (0,0): False,
    (1,0) : True,
    (0,1) :True,
    (1,1) : False
}
def main(str_bit):
    for i in range(8):
        last_bit = int(str_bit[-1])
        last_of_last_bit = int(str_bit[-2])
        
        bit_to_add_left = '1' if xor_truth_table[(last_of_last_bit, last_bit)] else '0'
        
        str_bit = bit_to_add_left + str_bit[:len(str_bit)-1]
        print(f"interation {i}: {str_bit}")
    
    return str_bit 


if __name__ == "__main__":
    import sys
    if len(sys.argv) <2:
        raise Exception("Missing requireed atribute byte. Example: python LSFR.py 11101110")
    
    main(sys.argv[1])
    
    
    