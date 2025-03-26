# with open("noisy_signal_adapted.txt", "w") as f_w:
    
#     with open("noisy_signal.txt", "r") as f_r:
#         for i in f_r.readlines():
#             f_w.write(f'"{i.strip()}",\n')
        
        
# with open("ram-content.txt" , "r") as f_r:
#     with open("ram-content-formated.txt", "w") as f_w:
#         content = f_r.read().replace("\n", " ")
#         for i in content.split(" "):
#             f_w.write(f'{i}\n')

def twos_complement(binary_str):
    bits = len(binary_str)
    value = int(binary_str, 2)
    # If the sign bit is set, subtract 2**bits
    if value & (1 << (bits - 1)):
        value -= (1 << bits)
    return value

with open("noisy_signal.txt", "r") as f_r:
   lines = f_r.readlines()
   signal = [twos_complement(line.strip()) for line in lines if line.strip()]
   
with open("filter_coefs.txt", "r") as f_r:
   lines = f_r.readlines()
   filter = [twos_complement(line.strip()) for line in lines if line.strip()]
   

result = []

def convolution(signal, filter):
    filter_length = len(filter)
    for i in range(len(signal) - filter_length + 1):
        conv_sum = sum(signal[i + j] * filter[j] for j in range(filter_length))
        result.append(conv_sum)

convolution(signal, filter)

print(result)
# import matplotlib.pyplot as plt
# plt.figure(figsize=(10, 4))
# plt.plot(result)
# plt.title("Signal (Two's Complement)")
# plt.xlabel("Sample Index")
# plt.ylabel("Amplitude")
# plt.grid(True)
# plt.show()
