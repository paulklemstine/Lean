def find_first_repeat(seq, k):
    seen = {}
    for i in range(len(seq) - k + 1):
        kmer = tuple(seq[i:i+k])
        if kmer in seen:
            return (seen[kmer], i, kmer)
        seen[kmer] = i
    return None