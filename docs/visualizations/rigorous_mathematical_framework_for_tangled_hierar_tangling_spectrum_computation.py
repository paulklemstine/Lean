def compute_tangling_spectrum(frame, max_k=20):
    spectrum = {}
    for w in range(frame.num_worlds):
        max_level = -1
        for k in range(max_k):
            if forces_in_frame(frame, {}, w, con_formula(k)):
                max_level = k
            else:
                break
        spectrum[w] = max_level
    return spectrum