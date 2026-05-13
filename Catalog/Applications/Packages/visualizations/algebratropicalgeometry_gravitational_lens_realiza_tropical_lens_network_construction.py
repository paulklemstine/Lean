def construct_lens_network(multiplicities):
    """Construct a reduced tropical lens network with given multiplicities."""
    return {
        "num_lenses": len(multiplicities),
        "cost_in": [0] * len(multiplicities),
        "cost_out": [0] * len(multiplicities),
        "path_mult": multiplicities
    }

# Example
network = construct_lens_network([7, 13])
print(f"Network: {network}")
print(f"Encoded product: {network['path_mult'][0] * network['path_mult'][1]}")