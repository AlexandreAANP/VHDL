with open("noisy_signal_adapted.txt", "w") as f_w:
    
    with open("noisy_signal.txt", "r") as f_r:
        for i in f_r.readlines():
            f_w.write(f'"{i.strip()}",\n')
        
        
