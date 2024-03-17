class workout():

    def __init__(self, place, muscle_group, intensity, name) -> None:
        self.place = place
        self.muscles = muscle_group
        self.intensity = intensity
        self.name = name

baseworkouts = [workout('in', ['legs'], 'muscle', 'squats'), workout('in', ['chest', 'arms'], 'muscle', 'pushups'), workout('in', ['abdomen'], 'muscle', 'crunches'), workout('in', ["hips", 'abdomen'], 'muscle', 'leg raises'), workout('in', ['abdomen', 'chest', 'arms'], 'muscle', 'plank'), 
                workout('', [''], '', ''), workout('', [''], '', ''), workout('', [''], '', ''), workout('', [''], '', ''), workout('', [''], '', ''), 
                workout('', [''], '', ''), workout('in', ['aerobic'], 'low', 'rowing machine'), workout('in', ['aerobic'], 'low', 'elliptical machine'), workout('in', ['aerobic'], 'low', 'dance'), workout('in', ['aerobic'], 'low', 'water aerobics'), 
                workout('out', ['aerobic'], 'low', 'hiking'), workout('in', ['aerobic'], 'high', 'jumping jacks'), workout('out', ['aerobic'], 'low', 'brisk walk'), workout('out', ['aerobic'], 'high', 'soccer'), workout('in', ['aerobic'], 'high', 'basketball'), 
                workout('out', ['aerobic'], 'high', 'tennis'), workout('out', ['aerobic'], 'low', 'cycling'), workout('out', ['aerobic'], 'high', 'sprints'), workout('out', ['aerobic'], 'high', 'jog'), workout('in', ['aerobic'], 'high', 'swimming laps')]