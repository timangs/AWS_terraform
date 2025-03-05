from flask import Flask, render_template, request, jsonify, session
import boto3
import json
from datetime import datetime, timedelta

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # 세션 관리를 위한 비밀 키 (실제로는 안전하게 관리)

# CloudTrail 클라이언트 생성 (EC2 인스턴스 역할 사용)
cloudtrail = boto3.client('cloudtrail', region_name='your-aws-region')  # 실제 리전


@app.route('/')
def index():
    """
    기본 페이지 (검색 폼)
    """
    # 세션에서 검색 조건 불러오기 (있는 경우)
    filters = session.get('filters', [])
    return render_template('index.html', filters=filters)


@app.route('/search', methods=['POST'])
def search():
    """
    CloudTrail 로그 검색 및 결과 반환 (단계별 필터링)
    """
    try:
        # 이전 검색 조건 가져오기 (세션에서)
        filters = session.get('filters', [])

        # 현재 요청의 필터 값 가져오기
        current_filter = {
            'key': request.form.get('filter_key'),
            'value': request.form.get('filter_value')
        }

        # 새 필터 추가 (값이 있는 경우에만)
        if current_filter['key'] and current_filter['value']:
          filters.append(current_filter)
          session['filters'] = filters  # 세션에 필터 저장


        # CloudTrail API 호출을 위한 LookupAttributes 구성
        lookup_attributes = []
        for f in filters:
            if f['key'] == 'start_time' or f['key'] == 'end_time':  # 시간 범위는 별도 처리
                continue
            lookup_attributes.append({'AttributeKey': f['key'], 'AttributeValue': f['value']})

        # 시간 범위 설정 (필터에 start_time, end_time이 있으면 사용, 없으면 기본값)
        start_time = session.get('start_time', datetime.utcnow() - timedelta(hours=1))
        end_time = session.get('end_time', datetime.utcnow())

        for f in filters:
          if f['key'] == 'start_time':
            start_time = datetime.fromisoformat(f['value'].replace("Z", "+00:00"))
            session['start_time'] = start_time #세션에 저장
          elif f['key'] == 'end_time':
            end_time = datetime.fromisoformat(f['value'].replace("Z", "+00:00"))
            session['end_time'] = end_time


        # CloudTrail API 호출
        response = cloudtrail.lookup_events(
            StartTime=start_time,
            EndTime=end_time,
            LookupAttributes=lookup_attributes,
            MaxResults=50  # 필요에 따라 조정
        )

        events = response.get('Events', [])

        # 이벤트 데이터 정제
        processed_events = []
        for event in events:
            processed_event = {
                'EventTime': event.get('EventTime').isoformat() if event.get('EventTime') else 'N/A',
                'EventName': event.get('EventName', 'N/A'),
                'Username': event.get('Username', 'N/A'),
                'EventSource': event.get('EventSource', 'N/A'),
                'CloudTrailEvent': json.loads(event.get('CloudTrailEvent')),  # JSON 객체
                'EventId' : event.get('EventId', 'N/A')
            }
            if 'Resources' in event:
                processed_event['Resources'] = event['Resources']
            processed_events.append(processed_event)


        return render_template('results.html', events=processed_events, filters=filters)

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/reset', methods=['POST'])
def reset_filters():
    """
    검색 조건(필터) 초기화
    """
    session.clear()  # 세션 데이터 모두 삭제
    return jsonify({'status': 'success'})

@app.route('/remove_filter', methods=['POST'])
def remove_filter():
    """
    특정 필터 제거
    """
    filter_index = int(request.form.get('index'))
    filters = session.get('filters', [])
    if 0 <= filter_index < len(filters):
        del filters[filter_index]
        session['filters'] = filters
    return jsonify({'status': 'success'})

@app.route('/view_event/<event_id>')
def view_event(event_id):
    """
     단일 이벤트의 전체 JSON 내용 보기
    """
    try:
        # CloudTrail API를 사용하여 이벤트 ID로 조회
        response = cloudtrail.lookup_events(
            LookupAttributes=[{'AttributeKey': 'EventId', 'AttributeValue': event_id}],
            MaxResults=1
        )

        events = response.get('Events', [])
        if not events:
            return jsonify({'error': 'Event not found'}), 404

        event_json = events[0].get('CloudTrailEvent')
        event_data = json.loads(event_json)  # JSON 문자열을 객체로 파싱

        return render_template('event_detail.html', event=event_data)

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)