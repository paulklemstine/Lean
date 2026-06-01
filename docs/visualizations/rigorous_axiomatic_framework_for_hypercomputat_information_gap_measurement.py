def compute_gaps(chain):
    return [chain[i+1] - chain[i] for i in range(len(chain)-1)]