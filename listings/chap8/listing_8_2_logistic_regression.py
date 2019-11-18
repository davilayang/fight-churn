import pandas as pd
import numpy as np
import os
from sklearn.linear_model import LogisticRegression
from math import exp
import pickle

def logistic_regression(data_set_path=''):
    X,y = prepare_data(data_set_path)
    retain_reg = LogisticRegression(penalty='l1', solver='liblinear', fit_intercept=True)
    retain_reg.fit(X, y)
    save_regression_summary(data_set_path,retain_reg)
    save_regression_model(data_set_path,retain_reg)
    save_dataset_predictions(data_set_path,retain_reg,X)

def prepare_data(data_set_path):
    score_save_path = data_set_path.replace('.csv', '_groupscore.csv')
    assert os.path.isfile(score_save_path), 'You must run listing 6.3 to save grouped metric scores first'
    grouped_data = pd.read_csv(score_save_path,index_col=[0,1])
    y = ~grouped_data['is_churn'].astype(np.bool)
    X = grouped_data.drop(['is_churn'],axis=1)
    return X,y

def calculate_impacts(retain_reg):
    average_churn=s_curve(retain_reg.intercept_)
    one_stdev_churns=np.array( [ s_curve(retain_reg.intercept_+c) for c in  retain_reg.coef_[0]])
    one_stdev_impact=average_churn-one_stdev_churns
    return one_stdev_impact, average_churn

def s_curve(x):
    return 1.0 - (1.0/(1.0+exp(-x)))

def save_regression_summary(data_set_path,retain_reg):
    one_stdev_impact,average_churn = calculate_impacts(retain_reg)
    group_lists = pd.read_csv(data_set_path.replace('.csv', '_groupmets.csv'),index_col=0)
    coef_df = pd.DataFrame.from_dict(
        {'group_metric_offset':  np.append(group_lists.index,'offset'),
         'weight': np.append(retain_reg.coef_[0],retain_reg.intercept_),
         'churn_impact' : np.append(one_stdev_impact,average_churn),
         'group_metrics' : np.append(group_lists['metrics'],'(baseline)')})
    save_path = data_set_path.replace('.csv', '_logreg_coef.csv')
    coef_df.to_csv(save_path, index=False)
    print('Saved coefficients to ' + save_path)

def save_regression_model(data_set_path,retain_reg):
    pickle_path = data_set_path.replace('.csv', '_logreg_model.pkl')
    with open(pickle_path, 'wb') as fid:
        pickle.dump(retain_reg, fid)
    print('Saved model pickle to ' + pickle_path)

def save_dataset_predictions(data_set_path, retain_reg, X):
    predictions = retain_reg.predict_proba(X)
    predict_df = pd.DataFrame(predictions,index=X.index,columns=['churn_prob','retain_prob'])
    predict_path = data_set_path.replace('.csv', '_predictions.csv')
    predict_df.to_csv(predict_path,header=True)
    print('Saved dataset predictions to ' + predict_path)
