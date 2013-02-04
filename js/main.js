$( function() {

  // Variables
  // Important! this library doesn't get jQuery Selectors, so some trick was required
  var canvas = $("#graph")[0];
  var stage = new createjs.Stage(canvas);
  var barValues = [];
  var barDescs = [];
  var Bars = [];
  var barWidth = 0;

  var preloader = new Preloder(stage, canvas);
  preloader.addToStage();

  // Loading the data
  $.ajax({
    url: 'http://www.socialbakers.com/countries/continents/',
    crossDomain: 'true',
    dataType: 'text',
    cache: true
  }).success( function(data){

      // Remove preloader
      preloader.removeFromStage();

      // Parse data
      $(data).find('.common-table tbody .percent').each( function(){
        barValues.push(parseFloat($(this).text()))})
        .end().find('.common-table tbody .text a').each( function(){
          barDescs.push($(this).text());
        });
      barWidth = parseInt(canvas.width/barValues.length);
      var graphCanvas = new createjs.Container();
      for (var i=1; i<6; i++) {
        var line = new createjs.Shape();
        var g = line.graphics;
        stage.addChild(line);

        line.graphics.beginFill('#DDD');
        for (var j=0; j<100; j++) {
          var x = (j/100*(canvas.width))+35;
          var y = (((canvas.height-25)/5)*i)+6;
          line.graphics.drawCircle(x,y,1);
          line.graphics.closePath();
        }

        label = new createjs.Text((5-i)*25+'%', "bold 10px Arial", "#999");
        label.textAlign = "right";
        label.x = 30;
        label.y = (((canvas.height-25)/5)*i);
        stage.addChild(label);
      }

      for (var i=0; i<barValues.length; i++) {
        var bar = new createjs.Container();
        var front = new createjs.Shape();
        front.scaleY = 0;
        front.x = 45 + barWidth*i;
        front.y = canvas.height-18;
        front.graphics.beginFill('#77b7c5').drawRect(0,0,barWidth/2,-(canvas.height-18)*barValues[i]/100);
        stage.addChild(front);
        createjs.Tween.get(front)
          .wait(i*100+500)
          .to({scaleY:1},700);

        var label = new createjs.Text(barValues[i]+ "%", "bold 10px Arial", "#666");
        label.textAlign = "center";
        label.x = 45 + (i*barWidth) + barWidth/4;
        label.y = canvas.height-38;
        stage.addChild(label);
        createjs.Tween.get(label)
          .wait(i*100+500)
          .to({y:(canvas.height-18-(canvas.height-18)*barValues[i]/100) -25},700);

        var desc = new createjs.Text(barDescs[i], "bold 10px Arial", "#333");
        desc.textAlign = "center";
        desc.x = 45 + (i*barWidth) + barWidth/4;
        desc.y = canvas.height-15;
        stage.addChild(desc);
      }
    });
  createjs.Ticker.setFPS(30);
  createjs.Ticker.addListener(stage,false);
});

Preloder = (function(){
  this.stage = null;
  this.preloader = null;
  function Preloder(stage,canvas){
    this.stage = stage;
    this.preloader = new createjs.Container();
    this.preloader.x = canvas.width/2 - 85;
    this.preloader.y = canvas.height/2 - 20;
    console.log(stage);
    for(var i=0;i<3;i++){
      var rect = new createjs.Shape();
      rect.graphics.beginFill("#DDD").drawRect(0,0,10,10);
      rect.x = 10+i*25;
      rect.y = i==1 ? 3 : 4;
      createjs.Tween.get(rect)
        .wait(i*350)
      createjs.Tween.get(rect, {loop:true})
        .wait(i*350)
        .to({scaleY:i==1 ? 1.8 : 1.3,
          scaleX:i==1 ? 1.8 : 1.3,
          y: i==1 ? 0 : 2,
          x: i==1 ? 7+i*25 : 9+i*25
        },700)
        .to({scaleY:1, scaleX:1, y: i==1 ? 3 : 4, x: 10+i*25},700);

      var preloaderText = new createjs.Text("Loading the data...", "bold 10px Arial", "#AAA");
      preloaderText.textAlign = "center";
      preloaderText.x = 42.5;
      preloaderText.y = 22;
      this.preloader.addChild(preloaderText, rect);
    }
  }

  Preloder.prototype.addToStage = function(){
    this.stage.addChild(this.preloader);
  };

  Preloder.prototype.removeFromStage = function(){
    createjs.Tween.get(this.preloader).to({alpha:0}, 300).call(this.stage.removeChild,this.preloader);
  };

  return Preloder;
})();

