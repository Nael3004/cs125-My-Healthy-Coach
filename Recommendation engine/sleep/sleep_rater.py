from sklearn.linear_model import *
from sklearn.neural_network import MLPRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
import pickle
import pandas as pd
import sys

def rep(x):
    if pd.isnull(x): 
        return 0
    else:
        return x

def train(data_source='Recommendation engine\sleep\Sleep_Efficiency.csv') -> None:
    model1 = RandomForestRegressor(n_estimators=250)
    model2 = MLPRegressor()

    data = pd.read_csv(data_source)

    data['Bedtime'] = data['Bedtime'].apply(lambda x: int(x[-2:]) + int(x[-5:-3]) * 60 + int(x[-8:-6]) * 3600)
    data['Wakeup time'] = data['Wakeup time'].apply(lambda x: int(x[-2:]) + int(x[-5:-3]) * 60 + int(x[-8:-6]) * 3600)
    data['Awakenings'] = data['Awakenings'].apply(rep)
    #data['Sleep efficiency'] = data['Sleep efficiency'].apply(lambda x: x * 100)
    print(data['Awakenings'])

    X_train, X_test, y_train, y_test = train_test_split(data[['Age', 'Bedtime', 'Wakeup time', 'Sleep duration', 'Awakenings']], data['Sleep efficiency'])

    model1.fit(X_train, y_train)
    #print(model1.score(X_test, y_test))
    #print(model1.score(data[['Age', 'Bedtime', 'Wakeup time', 'Sleep duration', 'Awakenings']], data['Sleep efficiency']))
    #model2.fit(X_train, y_train)
    #print(model2.score(X_test, y_test))
    #print(model2.score(data[['Age', 'Bedtime', 'Wakeup time', 'Sleep duration', 'Awakenings']], data['Sleep efficiency']))

    with open('Recommendation engine\sleep\sleep_rater_model.pkl', 'wb') as f:
        pickle.dump(model1, f)
    return model1.score(X_test, y_test)
    

    
def rate(Age, Bedtime, Wakeup_t, sleep_duration, awakenings) -> float:
    model = pickle.load('Recommendation engine\sleep\sleep_rater_model.pkl')
    return model.predict(Age, Bedtime, Wakeup_t, sleep_duration, awakenings)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Not enough arguments: please run again with train or score as arguments")
    else:
        if sys.argv[1] == 'train':
            if len(sys.argv) >= 3:
                print(train(sys.argv[2]))
            else:
                print(train())
        elif sys.argv[1] == 'score':
            if len(sys.argv) >= 7:
                print(train(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]))
            else:
                print("please run again with arguments for scoring")
        else:
            print("Invalid argument: please run again with train or score as arguments")