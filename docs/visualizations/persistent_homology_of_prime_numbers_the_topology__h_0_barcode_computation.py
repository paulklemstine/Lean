def compute_h0_barcode(points: list[float]) -> list[tuple[float,float]]:
    gaps = [points[i+1] - points[i] for i in range(len(points)-1)]
    bars = [(0.0, float(g)) for g in gaps]
    return sorted(bars, key=lambda b: b[1])