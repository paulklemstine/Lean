class StrangeLoopDetector:
    def find_loops(self):
        loops = []
        for start in range(self.levels):
            self._dfs(start, [start], set(), loops)
        return loops