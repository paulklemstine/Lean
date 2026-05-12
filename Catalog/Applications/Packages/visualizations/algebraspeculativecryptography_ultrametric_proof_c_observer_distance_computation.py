def compute_observer_distance(observations, x, y):
    """Compute observer disagreement distance."""
    return sum(1 for i in range(len(observations)) if observations[i][x] != observations[i][y])

def find_minimal_reconstruction(observations, n_states):
    """Find minimal observer subset that separates all state pairs."""
    n_obs = len(observations)
    T = set(range(n_obs))
    for i in list(T):
        T_prime = T - {i}
        separates = True
        for x in range(n_states):
            for y in range(x+1, n_states):
                if not any(observations[j][x] != observations[j][y] for j in T_prime):
                    separates = False
                    break
            if not separates: break
        if separates:
            T = T_prime
    return T

# Example
obs = [[0,0,1,1],[0,1,0,1],[1,0,0,1]]
print(f"Min reconstruction: {find_minimal_reconstruction(obs, 4)}")
for x in range(4):
    for y in range(x+1, 4):
        print(f"d({x},{y}) = {compute_observer_distance(obs, x, y)}")
