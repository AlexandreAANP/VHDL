data= ""
for i in range(50):
    data += '"'+format(i, '016b')+'"' + ",\n" if i != 49 else '"'+format(i, '016b')+'"'

    
print(data)
