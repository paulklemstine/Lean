import math

def generate_collatz_potential_viz():
    """Generate ASCII visualization of Collatz potential dynamics."""
    
    def collatz(n):
        return n // 2 if n % 2 == 0 else 3 * n + 1
    
    def log_potential(n):
        return math.log(n) if n > 0 else 0
    
    # Orbit of 27
    n = 27
    orbit = [n]
    while n != 1:
        n = collatz(n)
        orbit.append(n)
    
    potentials = [log_potential(x) for x in orbit]
    max_p = max(potentials)
    min_p = min(potentials)
    
    print("Collatz Potential Trajectory: n = 27")
    print("=" * 70)
    
    height = 20
    width = min(len(potentials), 70)
    step = max(1, len(potentials) // width)
    
    sampled = potentials[::step][:width]
    
    for row in range(height, -1, -1):
        threshold = min_p + (max_p - min_p) * row / height
        line = ""
        for p in sampled:
            line += "█" if p >= threshold else " "
        level = min_p + (max_p - min_p) * row / height
        print(f"{level:6.2f} |{line}|")
    
    print(f"       +{'-' * width}+")
    print(f"       0{' ' * (width-4)}step {len(orbit)-1}")
    print(f"
Peak: {max(orbit)} at potential {max_p:.4f}")
    print(f"Net change: {potentials[-1] - potentials[0]:.4f}")

generate_collatz_potential_viz()
