
ArrayList items;
ArrayList playlist;

ArrayList playlist_points;


int itemwidth = 125 * 6;
int itemheight = 50;
float camx = 0;
float camy = 0;

float font_verticaloffset = 20;

int number_of_children = 9;
int half_number_of_children = 4;

int canvaswidth = 1024;
int canvasheight = 600 + itemheight;

Point centerpoint = new Point(canvaswidth * 0.2f, canvasheight * 0.5f);
float rushspeed = 0.01f;

PFont myfont;
PFont myitfont;

//
// Logo images
//
PImage en_logo;
PImage en_logo_arc;
float en_logo_arc_rot = 0;
Point en_logo_pos;
boolean beachballvisible = false;

PImage flow_logo;
Point flow_logo_pos;
PImage welcome_blurb;
PImage content_providers;

//
// Export images
//
Button txt_export;
Button xpsf_export;
Button playlistify_export;

boolean preview_plays = true;

float playlistoffset = 0;
int playlistitemwidth = 180;

Item lastcrosseditem;

String console = "";

String query_string = "";
boolean hadFirstQuery = false;


float VectorLength(Point p){
  return sqrt(p.x * p.x + p.y * p.y);
}

class Animation{
  private Item i1;
  private Point fromp;
  private Point top;
  public Animation(Item ix, Point fp, Point tp){
    this.i1 = ix;
    this.fromp = fp;
    this.top = tp;
  }
  
  public boolean step(){
    Point v1 = new Point(top.x - fromp.x, top.y - fromp.y);
    float l1 = VectorLength(v1);
    v1.x /= l1;
    v1.y /= l1;
    
    this.i1.p.x += v1.x;
    this.i1.p.y += v1.y;
    
    v1 = new Point(top.x - i1.p.x, top.y - i1.p.y);
    if(VectorLength(v1) < 0.5f){
      this.i1.p.x = top.x;
      this.i1.p.y = top.y;
      return true;
    } else {
      return false;
    }
  }
}


class Point{
  public float x, y;
  public Point(float tx, float ty){
    this.x = tx;
    this.y = ty;
  }
}

class Item{
  public Point p;
  public float w,h;
  public float iw, ih;
  public boolean unfolded;
  
  public String artist;
  public String title;
  public String img_url;
  public PImage img;
  
  public float imgsize;
  public boolean isActive;
  
  public String echonestid;
  public String previewurl;
  
  private Point myul;
  private Point mydr;
  
  public Item(float nx, float ny, float nw, float nh){
    Point pp = new Point(nx, ny);
    this.p = pp;
    this.w = nw;
    this.iw = this.w * (5.0f / 12.0f);
    this.h = nh;
    this.ih = h;
    
    this.myul = new Point(nx, ny);
    this.mydr = new Point(nx + nw, ny + nh);
    
    this.imgsize = nh;
    this.img_url = "";
    this.previewurl = "";
    this.artist = "";
    this.title = "";
    this.img = en_logo;
  }
  
  public boolean isWithin(Point tp){
    if(tp.x >= p.x && tp.x <= (p.x + iw) &&
      tp.y >= p.y && tp.y <= (p.y + ih)){
        return true;
      } else {
        return false;
      }
  }
  
  public boolean isInViewport(Point ul, Point dr){
    if((mydr.x < ul.x || mydr.y < ul.y) || (myul.x > dr.x || myul.y > dr.y))
      return false;
    else
      return true;
  }
  
  public void spawnItems(){
    isActive = true;
    
    //javascript call:
    unfoldSong(echonestid);
    
    unfolded = true;
    //animate to center
    //camx = -p.x;
    //System.out.println("spawned!");
  }
}

class Button{
  private PImage b_;
  private PImage b_over;
  
  public Point pos;
  public float wid, hei;
  
  public Button(String i1, String i2){
    b_ = loadImage(i1);
    b_over = loadImage(i2);
    
    wid = 50;
    hei = 35;
    
    pos = new Point(0,0);
  }
  
  boolean mouseIsInside(){
    return (mouseX >= pos.x && mouseX <= pos.x + wid && mouseY >= pos.y && mouseY <= pos.y + hei);
  }
  
  void drawButton(){
    //check for mouse
    if(mouseIsInside()){
      image(b_over, pos.x, pos.y, wid, hei);
    } else {
      image(b_, pos.x, pos.y, wid, hei);
    }
  }
}


void drawPlaylistItem(Item it, float startx){
  pushMatrix();
  translate(startx, height - it.h);
  
  stroke(255,255,255);
  strokeWeight(1);
  noFill();
  
    fill(20);
    noStroke();
    rect(0,  - 5, it.iw, it.h + 10);

    //fill(220);
    fill(10);
    //stroke(255);
    rect(0, - 5, it.w, it.h + 10);
    //fill(200);

  image(it.img, 0, -5, it.imgsize + 5, it.imgsize + 5);
  
  textFont(myitfont, 14);
  
  //if(it.isActive)
    fill(255,255,255);
  //else
  //  fill(100);
  text(it.artist.toUpperCase(), it.imgsize + 5, font_verticaloffset);
  
  textFont(myfont, 24);
  text(it.title.toUpperCase(),it.imgsize + 5, font_verticaloffset + 20);

  popMatrix();
}

void drawPlaylistItem_OLD(Item it, float startx){
  //stroke(255,0,0);
  //strokeWeight(3);
  fill(0,0,0,0);

  if(it.isActive) {   
    fill(60,10,10,255);
    rect(startx, height - it.h, it.w, it.h + 10);
  } else {
    fill(30);
    rect(startx, height - it.h, it.w, it.h + 10);
  }

  image(it.img, startx, height - it.h, it.imgsize, it.imgsize);
  
  textFont(myfont, 14); 
  
  if(it.isActive)
    fill(230,230,230);
  else
    fill(255);
  text(it.artist, startx + it.imgsize + 5, height - it.h + font_verticaloffset );
  text(it.title, startx + it.imgsize + 5, height - it.h + font_verticaloffset + 20);
}


void drawItem(Item it){
  stroke(255,255,255);
  strokeWeight(1);
  noFill();
  
  if(it.isActive) {   
    //fill(245,200,200,255);
    stroke(255, 0, 0, 50);
    fill(255, 0, 0, 30);
    rect(it.p.x, it.p.y - 5, it.w, it.h + 10);
  } else {

    //fill(20);
    fill(255,255,255,5);
    noStroke();
    rect(it.p.x, it.p.y - 5, it.iw, it.h + 10);

    //fill(220);
    //fill(10);
    fill(255,255,255,5);
    //stroke(255);
    rect(it.p.x, it.p.y - 5, it.w, it.h + 10);
    //fill(200);
  }

  image(it.img, it.p.x, it.p.y + 2, it.imgsize, it.imgsize);
  
  textFont(myitfont, 14);
  
  //if(it.isActive)
  fill(255,255,255);
  //else
  //  fill(100);
  text(it.artist.toUpperCase(), it.p.x + it.imgsize + 5, it.p.y + font_verticaloffset);
  
  textFont(myfont, 24);
  text(it.title.toUpperCase(), it.p.x + it.imgsize + 5, it.p.y + font_verticaloffset + 20);
}

void drawPlaylist(){
  stroke(255);
  strokeWeight(3);
  fill(0);
  rect(-3, height - (itemheight + 5), canvaswidth + 10, itemheight + 10);
  pushMatrix();
  translate(playlistoffset, 0);
  
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    drawPlaylistItem(i1, i * playlistitemwidth);
    stroke(255,255,255);
    fill(255,255,255);
    rect(i * playlistitemwidth, height - (itemheight + 5), 5, itemheight + 10);
  }
  
  popMatrix();
}


void drawPlaylistExportMenu(){
  pushMatrix();
  translate(canvaswidth - (playlistitemwidth *1.5f), height - (itemheight + 4));
  fill(255);
  stroke(255);
  
  beginShape();
  vertex(0,0);
  vertex(playlistitemwidth *1.5f, 0);
  vertex(playlistitemwidth *1.5f, itemheight + 6);
  vertex(0, itemheight + 6);
  vertex(playlistitemwidth * 0.2f, itemheight / 2);
  endShape();

  //rect(0,0, playlistitemwidth, itemheight + 6);
  popMatrix();

  txt_export.drawButton();
  //xpsf_export.drawButton();
  if(playlist.size() > 2){
    //playlistify doesn't work for less than three songs
    playlistify_export.drawButton();
  }
}

void exportPlaylistToTxt(){
  String jspl = '<html><head></head><body><table><tr><th colspan=\'2\'>playlist:</th></tr>';
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    jspl = jspl + '<tr><td>' + (i+1) + '</td><td>' + i1.artist + '</td><td>' + i1.title + '</td></tr>';
  }
  jspl += '</table></body></html>';
  
  //javascript call
  exportTxtSongs(jspl);
}

void exportPlaylistToPlaylistify(){
  String jspl = '';
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    jspl = jspl + i1.artist + " - " + i1.title + "\n";
  }
  
  //javascript call
  exportPlaylistifySongs(jspl);
}


void exportPlaylistToSpotify(){
  String jspl = '';
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    jspl = jspl + i1.artist + " - " + i1.title + "\n";
  }
  
  //javascript call
  exportSpotifySongs(jspl);
}

void exportPlaylistToXPSF(){
  String jspl = '<![CDATA[';
  jspl += '<?xml version=\"1.0\" encoding=\"UTF-8\"?>';
  jspl += '<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">';
  jspl += '<trackList>'
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    jspl += '<track>';
    //my home is the cloud
    jspl += '<location>http://example.com/song_1.mp3<\/location>';
    jspl += '<creator>' + i1.artist + '<\/creator>';
    //jspl += '<album>' + i1.album + '</album>';
    jspl += '<title>' + i1.title + '<\/title>';
    jspl += '<image>' + i1.image_url + '<\/image>';
    jspl += '<\/track>';
  }
  jspl += '<\/trackList>';
  jspl += '<\/playlist>';
  jspl += ']]>';

  alert(jspl);
  
  exportXPSFSongs(jspl);
}


void setup(){
  items = new ArrayList();
  playlist = new ArrayList();

  playlist_points = new ArrayList();
  
  size(canvaswidth, canvasheight);
  noSmooth();
  
  en_logo = loadImage("img/echonest_logo.png");
  en_logo_arc = loadImage("img/logo_arc.gif");
  
  en_logo_pos = new Point(500, 500);

  flow_logo = loadImage("img/flowlist_logo.png");
  flow_logo_pos = new Point(200, 20);
  welcome_blurb = loadImage("img/intro_blurb.png");
  content_providers = loadImage("img/content.png");
  
  playlist_points.add(new Point(200 + 125, 20 + 70));
  
  txt_export = new Button("img/txt_button.png", "img/txt_button_over.png");
 // txt_export.pos = new Point(width - itemwidth, height - itemheight);
  txt_export.pos = new Point(canvaswidth - 120, canvasheight - itemheight + 3);
  
  //xpsf_export = new Button("img/xpsf_button.png", "img/xpsf_button_over.png");
  //xpsf_export.pos = new Point(canvaswidth - 140, canvasheight - itemheight + 3);
  
  playlistify_export = new Button("img/playlistify_button.png", "img/playlistify_button_over.png");
  playlistify_export.pos = new Point(canvaswidth - 60, canvasheight - itemheight + 3);
  
  /*Item i1 = new Item(300,300, itemwidth, itemheight);
  items.add(i1);*/
  
  myfont = loadFont("Sans-Serif");//loadFont("sfatari.svg");
  myitfont = loadFont("Sans-Serif Italic");
  
}

void draw(){
  background(0);
  
  //CANVAS
  pushMatrix();
  translate(camx, camy);
  
  noStroke();
  
  //draw logo and blurb
  if(camx > -500){
    image(flow_logo, flow_logo_pos.x, flow_logo_pos.y, 250, 125);
    
    image(welcome_blurb, flow_logo_pos.x, flow_logo_pos.y + 180, 250, 350);
    
    image(content_providers, 0, height - 195, 190, 90);
  }
  
  if(!hadFirstQuery){
    noStroke();
    fill(255);
    rect(flow_logo_pos.x, flow_logo_pos.y + 300, 280, 30);
    fill(0);
    textFont(myfont, 20);
    text(query_string, flow_logo_pos.x + 2, flow_logo_pos.y + 302 + font_verticaloffset);
  } else {
    stroke(230, 230, 230, 128);
    strokeWeight(2);
    noFill();
    Point lastpoint = (Point)playlist_points.get(0);
    for(int i = 1; i < playlist_points.size(); i++){
      Point currpoint = (Point)playlist_points.get(i);
      bezier(lastpoint.x, lastpoint.y, lastpoint.x, currpoint.y, lastpoint.x, currpoint.y, currpoint.x, currpoint.y);
      lastpoint = currpoint;
    }
    
    if(mouseIsDown){
      Point currpoint = transformToCanvas(new Point(mouseX, mouseY));
      bezier(lastpoint.x, lastpoint.y, lastpoint.x, currpoint.y, lastpoint.x, currpoint.y, currpoint.x, currpoint.y);
    }
  }
  
  
  //draw beachball
  if(beachballvisible){
    image(en_logo, en_logo_pos.x, en_logo_pos.y);
    //spinning part:
    pushMatrix();
    translate(en_logo_pos.x + 131, en_logo_pos.y + 83);
    rotate(en_logo_arc_rot);
    translate(-(en_logo_pos.x + 131), -(en_logo_pos.y + 83));
    image(en_logo_arc, (en_logo_pos.x + 111), (en_logo_pos.y + 62)); 
    popMatrix();
    en_logo_arc_rot += 0.04f;
  }
  
  Point vpul = transformToCanvas(new Point(0,0));
  Point vpdr = transformToCanvas(new Point(canvaswidth, canvasheight));
  
  //draw field
  for(int i = 0; i < items.size(); i++){
    Item i1 = (Item)items.get(i);
    if(i1.isInViewport(vpul, vpdr)){
      drawItem((Item)items.get(i));
    } /*else {
      console += "\n skipping " + i1.artist + " - " + i1.title;
    }*/
  }
    
  if(mouseIsDown){
    //collision detection
    checkForCollisions();
    
    //camera movement
    checkForCameraMovement();
  } 
  
  popMatrix();
  
  //UI ELEMENTS
  drawPlaylist();

  if(mouseIsDown){
    noFill();
    stroke(255, 200, 30, 128);
    strokeWeight(3);
    ellipse(mouseX, mouseY, 20, 20);
  } 

  if(mouseY >= (height - itemheight)){
    //hover over playlist
    drawPlaylistExportMenu();  
  }
    
  /*text(console, 0,30);
  Point cmouse = transformToCanvas(new Point(mouseX, mouseY));
  text(cmouse.x + ", " + cmouse.y, 0, 60);*/
}

void cleanRow(float xval){
  boolean foundSomething = false;
  do{  
    foundSomething = false;
    for(int i = 0; i < items.size(); i++){
      Item ix = (Item)items.get(i);
      if(abs(ix.p.x - xval) < 5){
        foundSomething = true;
        //console += "\n" + "removing " + ix.artist + " - " + ix.title;
        items.remove(i);
        i = items.size();  //break loop
      }
    }
  } while(foundSomething);
}


/*void cleanRow(float xval){
  ArrayList removeItems = new ArrayList();
  for(int i = 0; i < items.size(); i++){
    Item ix = (Item)items.get(i);
    if(abs(ix.p.x - xval) < 5){
      //console = "clean: " + ix.p.x + " at " + xval;
      console += "\n" + "removing " + ix.artist + " - " + ix.title;
      removeItems.add(ix);
    }
  }

  for(int i = 0; i < removeItems.size(); i++){
    items.remove(removeItems.get(i));
  }
}*/

void checkForCollisions(){
  Point mouseP = new Point(mouseX, mouseY);
  //transform point to canvas coordinates
  mouseP = transformToCanvas(mouseP);
 for(int i = 0; i < items.size(); i++){
   Item i1 = (Item)items.get(i);
   if(!i1.unfolded && i1.isWithin(mouseP)){
     console = "cleaning row " + (i1.p.x + itemwidth);
     cleanRow(i1.p.x + itemwidth);
     createEchonestBeachball(i1.p.x + itemwidth, i1.p.y);
     
     //javascript method:
     if(preview_plays){
       playSong(i1.previewurl);
     }
     
     i1.spawnItems();
     lastcrosseditem = i1;
     playlist.add(i1);
     
     playlist_points.add(new Point(i1.p.x + 20, i1.p.y + (i1.h / 2)));
     
     if(playlist.size() > (canvaswidth / playlistitemwidth)){
       playlistoffset -= playlistitemwidth;
     }
   }
 } 
}

void createEchonestBeachball(float startx, float starty){
  en_logo_pos = new Point(startx, starty);
  beachballvisible = true;
}

void removeEchonestBeachball(){
  beachballvisible = false;
}


void checkForCameraMovement(){
  if(mouseY < (height - itemheight)){

    float diffmx = mouseX - centerpoint.x;
    float diffmy = mouseY - centerpoint.y;
  
    camx -= rushspeed * diffmx;
    camy -= rushspeed * diffmy;
  }
}


Point transformToCanvas(Point p){
  return new Point(p.x - camx, p.y - camy);
}

boolean mouseIsDown;

void mousePressed(){
 mouseIsDown = true;
 
}

void mouseDragged(){
  
}

void mouseReleased(){
  mouseIsDown = false;
  //check for button release
  if(txt_export.mouseIsInside()){
    exportPlaylistToTxt();
  /*} else if(xpsf_export.mouseIsInside()){
    exportPlaylistToXPSF();*/
  } else if(playlistify_export.mouseIsInside()){
    exportPlaylistToPlaylistify();
  }
}

void keyTyped() {
  if(key == ENTER){
    //javascript call
    findSong(escape(query_string));
    
    createEchonestBeachball(width / 2 + 100, height / 2);
    hadFirstQuery = true;
    
  } else if(key == BACKSPACE){
    query_string = query_string.substring(0, query_string.length - 1);
  } else {
    query_string += String.fromCharCode(key);
  }
}

boolean songExists(String[] details){
  for(int i = 0; i < playlist.size(); i++){
    Item i1 = (Item)playlist.get(i);
    if(details[2].equals(i1.echonestid))
      return true;
  }
  return false;
}

void gotSongsP(String s, String callingitem){
  //alert("got songs!");
    
  float startx = 0;
  float starty = height / 2;
  if(lastcrosseditem != null){
    startx = lastcrosseditem.p.x;
    starty = lastcrosseditem.p.y;
  }
  
  console = "spawning items at " + (startx + itemwidth);
  
  String[] songs = split(s, '^');
  int act_num_child = min(half_number_of_children, songs.length / 2);
  float currentypos = starty - act_num_child * (itemheight * 1.5f);
  
  for(int i = 0; i < number_of_children && i < songs.length - 1; i++){
    String[] details = split(songs[i], '|');
    
    if(!songExists(details)){
      Item it = new Item(startx + itemwidth, currentypos, itemwidth, itemheight);
      currentypos = currentypos + (itemheight * 1.5f);
      it.title = details[0];
      it.artist = details[1];
      it.echonestid = details[2];
      it.img_url = details[3];
      it.previewurl = details[4];
      it.img = loadImage(it.img_url);
      //alert("added " + it.title + ", " + it.artist + ", " + it.img_url);
      items.add(it);
    }
  }
  
  removeEchonestBeachball();
}

