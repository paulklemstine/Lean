class OrdinalGameValue:
    def __init__(self, depth):
        self.depth = depth
    def __str__(self):
        if self.depth == 0: return 'n (finite)'
        if self.depth == 1: return 'ω'
        return f'ω^{self.depth}'
    def exceeds_finite(self):
        return self.depth >= 1