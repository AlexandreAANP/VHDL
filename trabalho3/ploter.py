import matplotlib.pyplot as plt

def twos_complement(binary_str):
    bits = len(binary_str)
    value = int(binary_str, 2)
    # If the sign bit is set, subtract 2**bits
    if value & (1 << (bits - 1)):
        value -= (1 << bits)
    return value

# Open and read the file (make sure it's in the same folder, baka)
with open('./noisy_signal.txt', 'r') as file:
    lines = file.readlines()


# Convert each line from two's complement to a signed integer
signal = [twos_complement(line.strip()) for line in lines if line.strip()]
print(signal)
# Plot the signal
plt.figure(figsize=(10, 4))
plt.plot(signal)
plt.title("Signal (Two's Complement)")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.grid(True)
plt.show()
