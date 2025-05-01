import matplotlib.pyplot as plt
import os

def twos_complement(binary_str):
    bits = len(binary_str)
    value = int(binary_str, 2)
    # If the sign bit is set, subtract 2**bits
    if value & (1 << (bits - 1)):
        value -= (1 << bits)
    return value

# Open and read the file (make sure it's in the same folder, baka)

dir_path = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(dir_path, './../output.txt'), 'r') as file:
    lines = file.readlines()


# Convert each line from two's complement to a signed integer
signal = [twos_complement(line.strip()) for line in lines if line.strip()]

# Plot the signal
plt.figure(figsize=(10, 4))
plt.plot(signal)
plt.title("Signal (Two's Complement)")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.grid(True)
plt.show()
