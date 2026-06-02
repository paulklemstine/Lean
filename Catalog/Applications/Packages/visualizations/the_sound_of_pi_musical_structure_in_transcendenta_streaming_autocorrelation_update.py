def streaming_update(r_n, digits, n_start, m_new, k, center=4.5):
    delta = sum((digits[n_start+i]-center)*(digits[n_start+i+k]-center) for i in range(m_new))
    return r_n + delta