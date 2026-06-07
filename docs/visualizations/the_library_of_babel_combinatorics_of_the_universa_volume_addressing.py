def volume_to_index(volume, A):
    index = 0
    for s in volume:
        index = index * A + s
    return index

def index_to_volume(index, A, L):
    volume = []
    for _ in range(L):
        volume.append(index % A)
        index //= A
    return volume[::-1]