//
//  GameViewController.m
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/6.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "GameViewController.h"
@import SceneKit;
#import "WZZRandomShape.h"
#import "WZZGameHelper.h"

@interface GameViewController ()<SCNSceneRendererDelegate, CBDStereoRendererDelegate>
{
    SCNView * mainView;
    SCNScene * mainScene;
    SCNNode * cameraNode;
    SCNNode * cameraContral;
    SCNNode * geoNode;
    NSTimeInterval mainTime;
    SCNRenderer *_renderer;
    NSTimer * testTimer;
    NSTimer * timeTimer;
    NSTimeInterval timee;
}

@end

@implementation GameViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.stereoRendererDelegate = self;
    }
    return self;
}

- (void)setup {
    //创建scn视图
    mainView = [[SCNView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:mainView];
    mainView.playing = YES;
    // 1
    mainView.showsStatistics = YES;
    // 2
    mainView.allowsCameraControl = YES;
    // 3
    mainView.autoenablesDefaultLighting = YES;
    
    //创建场景
    mainScene = [SCNScene scene];
    mainView.scene = mainScene;
    mainScene.background.contents = [UIColor blackColor];
    
    SCNNode * lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    [mainScene.rootNode addChildNode:lightNode];
    lightNode.position = SCNVector3Make(0, 50, 50);
    
    cameraContral = [SCNNode node];
    [mainScene.rootNode addChildNode:cameraContral];
    [cameraContral setPosition:SCNVector3Make(0, 5, 10)];
    //创建一个节点
    cameraNode = [SCNNode node];
    //设置节点的相机
    cameraNode.camera = [SCNCamera camera];
    //设置节点的位置
    cameraNode.position = SCNVector3Make(0, 0, 0);
    //将相机节点添加到场景的根节点上
    [cameraContral addChildNode:cameraNode];
    
    mainView.delegate = self;
    //添加方块
    //    [self spawnShape];
//    //判断时间
//    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        if (timee > mainTime) {//每隔多少秒一次
//            [self spawnShape];
//            mainTime = timee+(NSTimeInterval)([WZZGameHelper floatRandomWithMax:3 min:1]);
//        }
//        [self cleanScene];//清除超出屏幕的node
//    }];
//    //时间++
//    timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
//        timee++;
//    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 3) {
        [geoNode removeFromParentNode];
        [self spawnShape];
    }
}

- (void)spawnShape {
    SCNGeometry * geo;
    switch ([WZZRandomShape randomShape]) {
        case RSHAPE_Tube:
        {
            geo = [SCNTube tubeWithInnerRadius:1 outerRadius:2 height:1];
            NSLog(@"tube/空心圆柱体");
        }
            break;
        case RSHAPE_Cone:
        {
            geo = [SCNCone coneWithTopRadius:1 bottomRadius:2 height:1];
            NSLog(@"cone/圆台");
        }
            break;
        case RSHAPE_Torus:
        {
            geo = [SCNTorus torusWithRingRadius:1 pipeRadius:1];
            NSLog(@"torus/甜甜圈");
        }
            break;
        case RSHAPE_Sphere:
        {
            geo = [SCNSphere sphereWithRadius:1];
            NSLog(@"sphere/球");
        }
            break;
        case RSHAPE_Capsule:
        {
            geo = [SCNCapsule capsuleWithCapRadius:0.5 height:2];
            NSLog(@"capsule/胶囊");
        }
            break;
        case RSHAPE_Pyramid:
        {
            geo = [SCNPyramid pyramidWithWidth:1 height:1 length:1];
            NSLog(@"pyamid/4凌锥");
        }
            break;
        case RSHAPE_Cylinder:
        {
            geo = [SCNCylinder cylinderWithRadius:1 height:1];
            NSLog(@"cylinder/圆柱体");
        }
            break;
        default:
        {
            geo = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
        }
            break;
    }
    
    CGFloat red = arc4random()%256/255.0f;
    CGFloat green = arc4random()%256/255.0f;
    CGFloat blue = arc4random()%256/255.0f;
    geo.materials.firstObject.diffuse.contents = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    geoNode = [SCNNode nodeWithGeometry:geo];
    geoNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
    [mainScene.rootNode addChildNode:geoNode];
    
    float randomX = [WZZGameHelper floatRandomWithMax:2 min:-2];
    float randomY = [WZZGameHelper floatRandomWithMax:18 min:10];
    NSLog(@"%f, %f", randomX, randomY);
    SCNVector3 force = SCNVector3Make(randomX, randomY, 0);
    SCNVector3 posi = SCNVector3Make(0.05, 0.05, 0.05);
    [geoNode.physicsBody applyForce:force atPosition:posi impulse:YES];
    
//    [geoNode.physicsBody applyTorque:SCNVector4Make(0, 0, 3, 0) impulse:YES];
}

- (void)cleanScene {
    [mainScene.rootNode.childNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.position.y < -2) {
            [obj removeFromParentNode];
        }
    }];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 渲染循环代理
//渲染循环刚开始
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if (time > mainTime) {//每隔多少秒一次
        [self spawnShape];
        mainTime = time+(NSTimeInterval)([WZZGameHelper floatRandomWithMax:3 min:1]);
    }
    [self cleanScene];//清除超出屏幕的node
}

#pragma mark - 纸盒代理
- (void)setupRendererWithView:(GLKView *)glView {
    [EAGLContext setCurrentContext:glView.context];
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    
    [self setup];
    
    _renderer = [SCNRenderer rendererWithContext:glView.context options:nil];
    _renderer.scene = mainScene;
    _renderer.pointOfView = cameraNode;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        SCNAction *cameraMoveAction = [SCNAction moveTo:SCNVector3Make(-4.5f, -4.5f, 0.0f) duration:10.0f];
//        cameraMoveAction.timingMode = SCNActionTimingModeEaseInEaseOut;
//        [cameraContral runAction:cameraMoveAction];
//    });
}
- (void)shutdownRendererWithView:(GLKView *)glView
{
}

- (void)renderViewDidChangeSize:(CGSize)size
{
}

- (void)prepareNewFrameWithHeadViewMatrix:(GLKMatrix4)headViewMatrix
{
    // Disable GL_SCISSOR_TEST here due to an issue that causes parts of the screen not to be cleared on some devices
    // GL_SCISSOR_TEST is enabled again after returning from this function so no need to re-enable here.
    glDisable(GL_SCISSOR_TEST);
    // Perform glClear() because using SpriteKit's SKScene as a texture in SceneKit interferes with GL_SCISSOR_TEST
    // If you move glClear() to the start of -drawEyeWithEye:, the left side of the screen is cleared when the right eye is drawn
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)drawEyeWithEye:(CBDEye *)eye
{
    // Use Z-Up/Y-Forward because we are using a scene exported from Blender
    GLKMatrix4 lookAt = GLKMatrix4MakeLookAt(0.0f, 0.0f, 0.0f,
                                             0.0f, 1.0f, 0.0f,
                                             0.0f, 0.0f, 1.0f);
    cameraNode.transform = SCNMatrix4Invert(SCNMatrix4FromGLKMatrix4(GLKMatrix4Multiply([eye eyeViewMatrix], lookAt)));
    [cameraNode.camera setProjectionTransform:SCNMatrix4FromGLKMatrix4([eye perspectiveMatrixWithZNear:0.1f zFar:100.0f])];
    
    [_renderer renderAtTime:0];
}

- (void)finishFrameWithViewportRect:(CGRect)viewPort
{
}

@end
