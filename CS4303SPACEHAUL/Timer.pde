class Timer{
  private float timer = 60000; //default
  private float lastFrameMillis = 0;
  
  Timer(float milliseconds){
    this.timer = milliseconds;
  }
  
  private PVector getMinAndSecFromTimer(){ //absusing PVector notation to return minute and second values.
    int totalSeconds = floor(timer/1000);
    return new PVector(floor(totalSeconds/60), totalSeconds%60);
  }
  
  public void updateTimer(){ //This should always execute every frame, even if game is paused.
    float timeSinceLastFrame = millis();
    if(lastFrameMillis != 0){
      timeSinceLastFrame -= lastFrameMillis;
    }
    lastFrameMillis = millis();
    if(!CS4303SPACEHAUL.isPaused){
      timer -= timeSinceLastFrame; //only subtract from timer if game is not paused.
    }
  }
  
  public boolean outOfTime(){
    return (timer <= 0);
  }
  
  public void setTimer(int minutes, int seconds){
    timer = (minutes*60 + seconds)*1000;
  }
}
