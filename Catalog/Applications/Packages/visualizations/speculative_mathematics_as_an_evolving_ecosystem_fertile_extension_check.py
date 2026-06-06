def is_fertile(t1_ax, t1_th, t1_cn, t2_ax, t2_th, t2_cn):
    return t2_cn >= t1_cn and t1_cn > 0 and t2_th * t1_ax**2 > t1_th * t2_ax**2