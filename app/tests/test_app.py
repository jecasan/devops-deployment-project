import pytest
from app.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client
        
def test_home_returns_200(client):
    response = client.get('/')
    assert response.status_code == 200
    
def test_home_returns_json(client):
    response = client.get('/')
    data = response.get_json()
    assert data is not None
    assert 'message' in data

def test_health_check(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    
def test_nonexistent_route(client):
    response = client.get('/nonexistent')
    assert response.status_code == 404