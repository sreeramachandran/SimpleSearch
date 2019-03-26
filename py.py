from datetime import datetime
import requests


files = {'file': open('/home/raptor/Downloads/test_report.pdf', 'rb')}
r = requests.post(
'https://care-api-staging.appspot.com/reports/upload',
files=files,
data={
    'report_type': 'unit_activity',
    'start_date': '2019-03-04',
    'end_date': '2019-03-09',
    'period': 'monthly',
    'community_id': 'o9965q6opvgbmb7k9dn95nzmkvkm9d',
    'collection_id': 'w55ggokopnoxke6gmkpq5j8jqoav86',
    'collection_type': 'unit'
}
)