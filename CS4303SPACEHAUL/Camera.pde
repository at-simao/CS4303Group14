class Camera {
  private PVector firstTranslate; //translation to middle of respective player's screen (centre at 1/4 width for P1 and 3/4 width for P2)
  private PVector secondTranslate; //translation to middle of respective player's sprite
  private float zoom = 5.0f; //zoom
  //private float zoomX = 5.0f; //zoom
  //private float zoomY = 5.0f; //zoom
  private PVector position = new PVector(0,0);
  float heightUIOffset;
  
  
  final int CAMERA_FRAME_LAG = 15;
  PVector[] frameLagForCamera = new PVector[CAMERA_FRAME_LAG];
  int cameraLagIndex = 1;
  
  
  int playerFollowing = 1;

  
  
  public Camera(int x, int y, float zoom, float heightUIOffset, int playerFollowing) {
    this.firstTranslate = new PVector(x, y);
    this.zoom = zoom;
    for(int i = 0; i < CAMERA_FRAME_LAG; i++){
      frameLagForCamera[i] = new PVector(x,y);
    }
    this.heightUIOffset = heightUIOffset;
    this.playerFollowing = playerFollowing; //1 or 2
  }

  public void begin(PVector position) {
    //position == where player currently is. We place it at camera1LagIndex--, as we will only get to it after frameLagForCamera.length frames.
    if (cameraLagIndex == 0) {
      frameLagForCamera[frameLagForCamera.length - 1] = position.copy(); //wrap around to right-most index if in left-most/
    } else {
      frameLagForCamera[cameraLagIndex - 1] = position.copy(); //otherwise just place position behind where we are currently reading from.
    }
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    this.position.x = frameLagForCamera[cameraLagIndex].x;
    this.position.y = frameLagForCamera[cameraLagIndex].y;
    CS4303SPACEHAUL.offScreenBuffer.translate(width/4, height/2-heightUIOffset);
    CS4303SPACEHAUL.offScreenBuffer.scale(zoom);
    secondTranslate = new PVector(-this.position.x, -this.position.y);
    CS4303SPACEHAUL.offScreenBuffer.translate(-this.position.x, -this.position.y);
    cameraLagIndex++;
    if(cameraLagIndex >= frameLagForCamera.length) {
      cameraLagIndex = 0; //wrap-around.
    }
  }
  
  public void end() {
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
  }
  
  public PVector getFirstTranslation(){
    return firstTranslate;
  }
  
  public PVector getSecondTranslation(){
    return secondTranslate;
  }
  
  public float getZoom(){
    return zoom;
  }
  
  public void setZoom(float x, float y){ //used when scaling is not uniform between y and x.
    zoomX = x;
    zoomY = y;
  }
  
  public void setZoom(float x){
    zoom = x;
  }
  
  //public PVector applyTransformation(PVector worldCoordinates){
  //  PVector transformedResult = new PVector(worldCoordinates.x + firstTranslate.x, worldCoordinates.x + firstTranslate.x);
  //  transformedResult.mult(zoom);
  //  transformedResult.x = transformedResult.x + secondTranslate.x;
  //  transformedResult.y = transformedResult.y + secondTranslate.y;
  //  return transformedResult;
  //  //* getZoom()) + getSecondTranslation());
  //}
  
  public int getWhichPlayerFollowing(){
    return playerFollowing;
  }
  
  
}
