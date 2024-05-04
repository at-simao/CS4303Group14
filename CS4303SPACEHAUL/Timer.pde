class Timer{
  private float timer = 60000; //default
  private float timerStart = 60000; //default
  private float lastFrameMillis = 0;
  
  //display attributes
  private PVector position = null;
  private float radius = 35;
  
  private color toGo;
  private color spent;
  
  Timer(float milliseconds, PVector position, float radius){
    this.timer = milliseconds;
    this.timerStart = milliseconds;
    this.position = position;
    this.radius = radius;
    this.toGo = color(0,200,0); // colour representing time remaining.
    this.spent = color(200,0,0); // colour representing time remaining.
  }
  
  Timer(float milliseconds, PVector position, float radius, color toGo, color spent){
    this.timer = milliseconds;
    this.timerStart = milliseconds;
    this.position = position;
    this.radius = radius;
    this.toGo = toGo; // colour representing time remaining.
    this.spent = spent; // colour representing time remaining.
  }
  
  private PVector getMinAndSecFromTimer(){ //absusing PVector notation to return minute and second values.
    int totalSeconds = floor(timer/1000);
    return new PVector(floor(totalSeconds/60), totalSeconds%60);
  }
  
  public void updateTimer(){ //This should always execute every frame, even if game is paused.
    float timeSinceLastFrame = millis();
    if(lastFrameMillis == 0){
      lastFrameMillis = millis();
      return; //wait to compare next frame when we have actual measurement.
    }
    timeSinceLastFrame -= lastFrameMillis;
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
    timerStart = timer;
  }
  
  public float getMaxTime(){
    return timerStart;
  }
  
  public float getCurrTime(){
    return timer;
  }
  
  public void uiDraw(){ //call to draw timer associated with a given mission. 
    pushMatrix();
    translate(position.x, position.y);
    fill(0,200,0);
    circle(0,0,radius);
    fill(200,0,0);
    rotate(-HALF_PI);
    arc(0,0,radius,radius,0, TWO_PI*(1 - timer/timerStart));
    popMatrix();
  }
  
  public void draw(){ //call to draw timer associated with a given mission. 
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(toGo);
    CS4303SPACEHAUL.offScreenBuffer.circle(0,0,radius);
    CS4303SPACEHAUL.offScreenBuffer.fill(spent);
    CS4303SPACEHAUL.offScreenBuffer.rotate(-HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.arc(0,0,radius,radius,0, TWO_PI*(1 - timer/timerStart));
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
  }
}
