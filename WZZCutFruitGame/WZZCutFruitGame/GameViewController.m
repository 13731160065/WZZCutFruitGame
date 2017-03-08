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

@interface GameViewController ()
{
    SCNView * mainView;
    SCNScene * mainScene;
    SCNNode * cameraNode;
    SCNNode * geoNode;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建scn视图
    mainView = [[SCNView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mainView];
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
    
    //创建一个节点
    cameraNode = [SCNNode node];
    //设置节点的相机
    cameraNode.camera = [SCNCamera camera];
    //设置节点的位置
    cameraNode.position = SCNVector3Make(0, 0, 10);
    //将相机节点添加到场景的根节点上
    [mainScene.rootNode addChildNode:cameraNode];
    
    //添加方块
    [self spawnShape];
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
    geoNode = [SCNNode nodeWithGeometry:geo];
    geoNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
    [mainScene.rootNode addChildNode:geoNode];
    
    float randomX = [WZZGameHelper floatRandomWithMax:2 min:-2];
    float randomY = [WZZGameHelper floatRandomWithMax:10 min:18];
    SCNVector3 force = SCNVector3Make(randomX, randomY, 0);
    SCNVector3 posi = SCNVector3Make(0.05, 0.05, 0.05);
    [geoNode.physicsBody applyForce:force atPosition:posi impulse:YES];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
