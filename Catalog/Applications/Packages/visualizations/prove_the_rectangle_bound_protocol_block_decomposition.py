def decompose_protocol(R, n, messages, costs):
    """Decompose protocol into consecutive blocks."""
    return [(k*n, messages[k*n:(k+1)*n], costs[k*n:(k+1)*n])
            for k in range(R // n)]